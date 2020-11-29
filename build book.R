bookdown::render_book("index.Rmd", "bookdown::gitbook")

bookdown::serve_book(output_dir = "docs")
