// Force bundling of all dependencies for Docker deployment
// NOTE: tesseract.js and pdf-parse are heavy - may still fail
export default {
	plugins: [],
	// Mark nothing as external - bundle everything
	external: [],
};
