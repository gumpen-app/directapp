import { defineEndpoint } from '@directus/extensions-sdk';
import Joi from 'joi';
import pdfParse from 'pdf-parse';
import { createWorker } from 'tesseract.js';

export default defineEndpoint({
  id: 'parse-order-pdf',
  handler: (router, { services, getSchema }) => {
    const { ItemsService } = services;

    // POST /parse-order-pdf - Extract text from PDF or image
    router.post('/', async (req, res, next) => {
      try {
        const accountability = req.accountability;

        if (!accountability) {
          return res.status(401).json({ error: 'Authentication required' });
        }

        // Validate request
        const schema = Joi.object({
          file_id: Joi.string().required(),
        });

        const { error, value } = schema.validate(req.body);

        if (error) {
          return res.status(400).json({ error: error.details[0].message });
        }

        const { file_id } = value;

        // Get file from directus_files
        const filesService = new ItemsService('directus_files', {
          accountability,
          schema: await getSchema(),
        });

        const file = await filesService.readOne(file_id, {
          fields: ['id', 'type', 'filename_disk'],
        });

        if (!file) {
          return res.status(404).json({ error: 'File not found' });
        }

        // Read file buffer
        const fileBuffer = await filesService.readOne(file_id, {
          fields: ['*'],
        });

        let extractedText = '';

        // Extract text based on file type
        if (file.type === 'application/pdf') {
          // Parse PDF
          const data = await pdfParse(fileBuffer);
          extractedText = data.text;
        } else if (file.type?.startsWith('image/')) {
          // OCR image using Tesseract
          const worker = await createWorker('eng');
          const { data } = await worker.recognize(fileBuffer);
          extractedText = data.text;
          await worker.terminate();
        } else {
          return res.status(400).json({
            error: 'Unsupported file type. Only PDF and images are supported.',
          });
        }

        // Extract vehicle order data using regex patterns
        const extractedData = extractOrderData(extractedText);

        return res.json({
          success: true,
          data: {
            raw_text: extractedText,
            extracted: extractedData,
          },
        });
      } catch (err: any) {
        console.error('Parse order PDF error:', err);
        return res.status(500).json({ error: err.message });
      }
    });
  },
});

/**
 * Extract vehicle order data from text using regex patterns
 */
function extractOrderData(text: string): Record<string, any> {
  const data: Record<string, any> = {};

  // VIN Pattern (17 characters, alphanumeric, no I, O, Q)
  const vinMatch = text.match(/\b([A-HJ-NPR-Z0-9]{17})\b/i);

  if (vinMatch) {
    data.vin = vinMatch[1].toUpperCase();
  }

  // Order Number Pattern (various formats)
  const orderPatterns = [
    /ordrenr[:\s]*([A-Z0-9\-]+)/i,
    /order\s*number[:\s]*([A-Z0-9\-]+)/i,
    /ordre[:\s]*([A-Z0-9\-]+)/i,
    /bestillingsnr[:\s]*([A-Z0-9\-]+)/i,
  ];

  for (const pattern of orderPatterns) {
    const match = text.match(pattern);

    if (match) {
      data.order_number = match[1].trim();
      break;
    }
  }

  // Customer Name Pattern
  const customerPatterns = [
    /kunde[:\s]*([A-ZÆØÅa-zæøå\s]+?)(?:\n|$)/i,
    /customer[:\s]*([A-Za-z\s]+?)(?:\n|$)/i,
    /navn[:\s]*([A-ZÆØÅa-zæøå\s]+?)(?:\n|$)/i,
  ];

  for (const pattern of customerPatterns) {
    const match = text.match(pattern);

    if (match) {
      data.customer_name = match[1].trim();
      break;
    }
  }

  // Brand/Model Pattern
  const brandMatch = text.match(/(?:merke|brand)[:\s]*([A-Za-z]+)/i);

  if (brandMatch) {
    data.brand = brandMatch[1].trim();
  }

  const modelMatch = text.match(/(?:modell|model)[:\s]*([A-Za-z0-9\s\-]+?)(?:\n|$)/i);

  if (modelMatch) {
    data.model = modelMatch[1].trim();
  }

  // Year Pattern
  const yearMatch = text.match(/(?:årsmodell|year|årgang)[:\s]*(\d{4})/i);

  if (yearMatch) {
    data.model_year = parseInt(yearMatch[1]);
  }

  // Delivery Date Pattern
  const deliveryPatterns = [
    /leveringsdato[:\s]*(\d{2}[.\-/]\d{2}[.\-/]\d{4})/i,
    /delivery\s*date[:\s]*(\d{2}[.\-/]\d{2}[.\-/]\d{4})/i,
    /levering[:\s]*(\d{2}[.\-/]\d{2}[.\-/]\d{4})/i,
  ];

  for (const pattern of deliveryPatterns) {
    const match = text.match(pattern);

    if (match) {
      data.expected_delivery_date = match[1];
      break;
    }
  }

  // License Plate Pattern (Norwegian: 2 letters + 5 digits or 2 letters + 4 digits)
  const licensePlateMatch = text.match(/\b([A-Z]{2}\s*\d{4,5})\b/);

  if (licensePlateMatch) {
    data.license_plate = licensePlateMatch[1].replace(/\s/g, '');
  }

  // Color Pattern
  const colorPatterns = [
    /farge[:\s]*([A-ZÆØÅa-zæøå]+)/i,
    /color[:\s]*([A-Za-z]+)/i,
  ];

  for (const pattern of colorPatterns) {
    const match = text.match(pattern);

    if (match) {
      data.color = match[1].trim();
      break;
    }
  }

  return data;
}
