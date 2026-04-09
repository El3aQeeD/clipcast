CREATE OR REPLACE FUNCTION get_setup_podcasts_grouped(
  p_categories text[],
  p_per_category int DEFAULT 2,
  p_offset int DEFAULT 0,
  p_limit int DEFAULT 20
)
RETURNS TABLE(
  id uuid,
  title text,
  artwork_url text,
  author text,
  categories text[],
  category_group text
)
LANGUAGE sql STABLE
AS $$
  SELECT sub.id, sub.title, sub.artwork_url, sub.author, sub.categories, sub.category_group
  FROM (
    SELECT p.id, p.title, p.artwork_url, p.author, p.categories,
           cat AS category_group,
           ROW_NUMBER() OVER (PARTITION BY cat ORDER BY p.title) AS rn
    FROM podcasts p, unnest(p.categories) AS cat
    WHERE cat = ANY(p_categories)
  ) sub
  WHERE sub.rn <= p_per_category
  ORDER BY sub.category_group, sub.rn
  OFFSET p_offset
  LIMIT p_limit;
$$;
