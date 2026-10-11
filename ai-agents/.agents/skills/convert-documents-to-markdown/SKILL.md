---
name: convert-documents-to-markdown
description: Convert Word (.doc, .docx), PowerPoint (.ppt, .pptx), Excel (.xls, .xlsx), OpenDocument (.odt, .ods, .odp), RTF, EPUB, CSV, and PDF files to GitHub-Flavored Markdown. Use when a task needs the contents of an office document, spreadsheet, presentation, ebook, or PDF you cannot read directly.
license: MIT
metadata:
  author: firecrawl
---

# Convert documents to Markdown

Run the anydoc CLI (installed globally on this machine). On another machine, `npx -y @firecrawl/anydoc` works without installing (needs Node 20+):

```bash
anydoc <file>              # Markdown to stdout
anydoc <file> -o out.md    # write to a file
anydoc - --format csv < f  # read stdin
```

Rules:

1. Supported inputs: `.doc`, `.docx`, `.docm`, `.odt`, `.rtf`, `.epub`, `.pdf`, `.ppt`, `.pps`, `.pot`, `.pptx`, `.pptm`, `.ppsx`, `.ppsm`, `.odp`, `.xls`, `.xlsx`, `.xlsm`, `.xlsb`, `.ods`, `.csv`.
2. The format is detected from the file content. Pass `--format <name>` only when detection cannot work: CSV from stdin, or a missing or wrong extension.
3. Exit codes: 0 success, 1 the document could not be converted, 2 usage error, 3 pages of a PDF need OCR. Failures print one `anydoc: <message>` line to stderr. The CLI never prompts.
4. For a large document, write to a file with `-o` and read the parts you need instead of streaming everything into context.
5. Scanned and image-only pages need OCR, which anydoc does not do: exit 3, and the stderr message names the offending pages. Never call a hosted OCR service; work locally, in order:
   1. Rasterize the failing pages: `pdftoppm -f N -l N -r 150 -png doc.pdf page`
   2. If your model reads images, Read the PNGs and transcribe them faithfully to Markdown yourself, preserving structure (headings, lists, tables).
   3. Otherwise send each PNG to the user's local vision model through the ollama daemon (its cloud models include vision, e.g. `gemma4:cloud`): `curl -s http://localhost:11434/api/chat -d '{"model":"gemma4:cloud","stream":false,"messages":[{"role":"user","content":"Transcribe the page image faithfully to Markdown. Preserve headings, lists and tables.","images":["<base64 of PNG>"]}]}' | jq -r '.message.content'`. If the daemon is not running, start it once with `ollama run gemma4:cloud`.
   4. Offline OCR engines (no network). Check which is installed and use the first available:
      - glm-ocr via ollama (multilingual, document-specialized): `ollama list | grep glm-ocr` detects it, then per page: `curl -s http://localhost:11434/api/generate -d '{"model":"glm-ocr:q8_0","prompt":"Text Recognition:","images":["<base64>"],"stream":false}' | jq -r '.response'`. Use `Table Recognition:` for tables, `Figure Recognition:` for figures.
      - tesseract: `tesseract page-N.png - -l <doc languages, e.g. spa+eng> --psm 6`
      If neither is installed, ask the user which one to install before proceeding: `ollama pull glm-ocr:q8_0` (multilingual, highest document quality, needs GPU VRAM free to be fast) or `sudo apt install tesseract-ocr tesseract-ocr-spa` (minimal footprint, CPU only).
   anydoc returns nothing for such a PDF, so assemble the final Markdown yourself: OCR the pages named in the error with the chain above, extract the remaining pages' text with pypdf, and keep reading order.
6. Inside a Node, Python, or Rust codebase, prefer the library over shelling out: `@firecrawl/anydoc` on npm, `firecrawl-anydoc` on PyPI, `anydoc` on crates.io. Each exposes the same `to_markdown` / `toMarkdown` API.
