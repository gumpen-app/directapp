-- Fix for "cannot change return type of existing function" error
-- This version DROPS functions first, then recreates them with correct return type

-- Step 1: Drop existing functions
DROP FUNCTION IF EXISTS search_workflows(vector, integer);
DROP FUNCTION IF EXISTS find_plugin_patterns(vector, text, integer);
DROP FUNCTION IF EXISTS find_mcp_capabilities(vector, text, integer);

-- Step 2: Recreate with correct return type (JSONB format)

CREATE OR REPLACE FUNCTION search_workflows(
  query_embedding vector(384),
  limit_count integer DEFAULT 10
)
RETURNS TABLE (
  item jsonb,
  similarity float
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    jsonb_build_object(
      'id', w.id,
      'workflow_name', w.workflow_name,
      'content', w.content,
      'category', w.category,
      'relevance_score', w.relevance_score,
      'last_accessed', w.last_accessed,
      'access_count', w.access_count,
      'created_at', w.created_at
    ) as item,
    (1 - (w.embedding <=> query_embedding))::float as similarity
  FROM workflow_memories w
  WHERE w.embedding IS NOT NULL
    AND (1 - (w.embedding <=> query_embedding)) > 0.5
  ORDER BY similarity DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION find_plugin_patterns(
  query_embedding vector(384),
  p_interface_type text,
  limit_count integer DEFAULT 10
)
RETURNS TABLE (
  item jsonb,
  similarity float
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    jsonb_build_object(
      'id', p.id,
      'plugin_name', p.plugin_name,
      'interface_type', p.interface_type,
      'pattern_yaml', p.pattern_yaml,
      'success_rate', p.success_rate,
      'implementations', p.implementations,
      'last_validated', p.last_validated,
      'created_at', p.created_at
    ) as item,
    (1 - (p.pattern_embedding <=> query_embedding))::float as similarity
  FROM plugin_patterns p
  WHERE p.interface_type = p_interface_type
    AND p.pattern_embedding IS NOT NULL
    AND (1 - (p.pattern_embedding <=> query_embedding)) > 0.6
    AND p.success_rate > 0.7
  ORDER BY p.success_rate DESC, similarity DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION find_mcp_capabilities(
  query_embedding vector(384),
  tier_filter text DEFAULT NULL,
  limit_count integer DEFAULT 10
)
RETURNS TABLE (
  item jsonb,
  similarity float
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    jsonb_build_object(
      'id', m.id,
      'mcp_name', m.mcp_name,
      'capability', m.capability,
      'description', m.description,
      'tier_requirement', m.tier_requirement,
      'latency_ms', m.latency_ms,
      'last_used', m.last_used,
      'usage_count', m.usage_count,
      'created_at', m.created_at
    ) as item,
    (1 - (m.capability_embedding <=> query_embedding))::float as similarity
  FROM mcp_capability_memory m
  WHERE m.capability_embedding IS NOT NULL
    AND (tier_filter IS NULL OR m.tier_requirement = tier_filter)
    AND (1 - (m.capability_embedding <=> query_embedding)) > 0.5
  ORDER BY similarity DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Functions updated successfully!';
  RAISE NOTICE 'Fixed: search_workflows, find_plugin_patterns, find_mcp_capabilities';
  RAISE NOTICE 'Return type: TABLE (item jsonb, similarity float)';
END $$;
