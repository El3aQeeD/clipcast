/**
 * Deploy seed-onboarding-data to Supabase using the Management API (same as Supabase CLI).
 * Requires: SUPABASE_ACCESS_TOKEN (Dashboard → Account → Access Tokens)
 *
 * Usage (PowerShell):
 *   $env:SUPABASE_ACCESS_TOKEN="your_pat"
 *   node scripts/deploy-seed-edge-fn.mjs
 */
import { readFileSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");

const PROJECT_REF = "whmdnwsttwnwxuumacwp";
const SLUG = "seed-onboarding-data";
const FN_DIR = "supabase/functions/seed-onboarding-data";

const token = process.env.SUPABASE_ACCESS_TOKEN?.trim();
if (!token) {
  console.error("Missing SUPABASE_ACCESS_TOKEN");
  process.exit(1);
}

const entryContent = readFileSync(join(root, FN_DIR, "index.ts"), "utf8");
const genresContent = readFileSync(join(root, FN_DIR, "genres.json"), "utf8");

const metadata = {
  name: SLUG,
  entrypoint_path: "index.ts",
  import_map_path: null,
  verify_jwt: false,
};

const boundary = "----clipcastBoundary" + Math.random().toString(36).slice(2);

function buildMultipartBody() {
  const chunks = [];
  const push = (s) => chunks.push(Buffer.from(s, "utf8"));

  push(`--${boundary}\r\n`);
  push(`Content-Disposition: form-data; name="metadata"\r\n`);
  push(`Content-Type: application/json\r\n\r\n`);
  push(JSON.stringify(metadata));
  push(`\r\n--${boundary}\r\n`);
  push(
    `Content-Disposition: form-data; name="file"; filename="index.ts"\r\n`,
  );
  push(`Content-Type: application/typescript\r\n\r\n`);
  push(entryContent);
  push(`\r\n--${boundary}\r\n`);
  push(
    `Content-Disposition: form-data; name="file"; filename="genres.json"\r\n`,
  );
  push(`Content-Type: application/json\r\n\r\n`);
  push(genresContent);
  push(`\r\n--${boundary}--\r\n`);
  return Buffer.concat(chunks);
}

const body = buildMultipartBody();
const url = `https://api.supabase.com/v1/projects/${PROJECT_REF}/functions/deploy?slug=${encodeURIComponent(SLUG)}`;

const res = await fetch(url, {
  method: "POST",
  headers: {
    Authorization: `Bearer ${token}`,
    "Content-Type": `multipart/form-data; boundary=${boundary}`,
    "Content-Length": String(body.length),
  },
  body,
});

const text = await res.text();
if (!res.ok) {
  console.error(res.status, text);
  process.exit(1);
}
console.log(text);
