# render-plantuml-action

A GitHub Action for rendering `*.{plantuml,puml}` files to SVG, PNG files, or both.

## Inputs

### `formats`

**Optional:** A comma-separated list of the formats to render. Supported formats are: `svg,png`.

**Default:** `svg`

Examples:

- `png,svg`
- `svg`
- `png`

### `sub-dirs`

**Optional:** A comma-separated list of what directories to search for PlantUML files

**Default:** `.`

Examples:

- `.`
- `docs,content/sketches`

### `skip-dirs`

**Optional:** A comma-separated list of what directories to skip when searching for PlantUML files

**Default:** `.git`

Examples:

- `.git`
- `foo/dont_include,bar/dont_include`

### `files`

**Optional:** A comma-separated list of specific files to convert, in the form: "dest-file:src-file"

**Default:** Empty

Examples:

- `docs/images/sketch.png:docs/drawings/sketch.puml`
- `docs/backup-sketch.svg:docs/drawings/sketch.uml.bak`

### `log-level`

**Optional:** What log level to use. Recognized levels are "info" and "debug".

**Default:** `info`

Examples:

- `info`
- `debug`

## Output

### `rendered-files`

A space-separated list of files that were rendered, can be passed to e.g. "git add"

Example:

- `test/sketch.svg test/sketch.png diagrams/intro.png`

## Usage Example

The following example Github Action pushes a new commit with the generated files.

```yaml
on: [push]

jobs:
  render_drawio:
    runs-on: ubuntu-latest
    name: Render PlantUML files
    steps:
    - name: Checkout
      uses: actions/checkout@v2
    - name: Render PlantUML files
      uses: ghcr.io/racklet/render-plantuml-action@v1
      id: render
      with: # Showcasing the default values here
        formats: 'svg'
        sub-dirs: '.'
        skip-dirs: '.git'
        # files: '' # unset, specify "dest-file:src-file" mappings here
        log-level: 'info'
    - name: Print the rendered files
      run: 'echo "The following files were generated: ${{ steps.render.outputs.rendered-files }}"'
    - uses: EndBug/add-and-commit@v7
      with:
        # This "special" author name and email will show up as the GH Actions user/bot in the UI
        author_name: github-actions
        author_email: 41898282+github-actions[bot]@users.noreply.github.com
        message: 'Automatically render PlantUML files'
        add: "${{ steps.render.outputs.rendered-files }}"
```

## Docker

You can use it standalone as well, through the Docker container:

```console
$ docker run -it -v $(pwd):/files ghcr.io/racklet/render-plantuml-action:v1 --help
Usage of /render-plantuml:
  -f, --files stringToString   Comma-separated list of files to render, of form 'dest-file=src-file'. The extension for src-file can be any of [plantuml puml], and for dest-file any of [png svg] (default [])
      --formats strings        Comma-separated list of formats to render the files as, for use with --subdirs (default [svg])
      --log-level Level        What log level to use (default info)
  -r, --root-dir string        Where the root directory for the files that should be rendered are. (default "/files")
  -s, --skip-dirs strings      Comma-separated list of sub-directories of --root-dir to skip when recursively checking for files to convert (default [.git])
  -d, --sub-dirs strings       Comma-separated list of sub-directories of --root-dir to recursively search for files to render (default [.])
pflag: help requested
```

Sample Docker usage:

```console
$ docker run -it -v $(pwd):/files ghcr.io/racklet/render-drawio-action:v1
{"level":"info","msg":"Got config","cfg":{"RootDir":"/files","SubDirs":["."],"SkipDirs":[".git"],"Files":{},"SrcFormats":["plantuml","puml"],"ValidSrcFormats":["plantuml","puml"],"DestFormats":["svg","png"],"ValidDestFormats":["png","svg"]}}
{"level":"info","msg":"Created os.DirFS at /files"}
{"level":"info","msg":"Walking subDir ."}
{"level":"info","msg":"Rendering test/foo.puml -> test/foo.svg"}
{"level":"info","msg":"Rendering test/foo.puml -> test/foo.png"}
{"level":"info","msg":"Setting Github Action output","rendered-files":"/files/test/foo.svg /files/test/foo.png"}
::set-output name=rendered-files::/files/test/foo.svg /files/test/foo.png
```

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) and our [Code Of Conduct](CODE_OF_CONDUCT.md).

Other interesting resources include:

- [The issue tracker](https://github.com/racklet/racklet/issues)
- [The discussions forum](https://github.com/racklet/racklet/discussions)
- [The list of milestones](https://github.com/racklet/racklet/milestones)
- [The roadmap](https://github.com/orgs/racklet/projects/1)
- [The changelog](CHANGELOG.md)

## Getting Help

If you have any questions about, feedback for or problems with Racklet:

- Invite yourself to the [Open Source Firmware Slack](https://slack.osfw.dev/).
- Ask a question on the [#racklet](https://osfw.slack.com/messages/racklet/) slack channel.
- Ask a question on the [discussions forum](https://github.com/racklet/racklet/discussions).
- [File an issue](https://github.com/racklet/racklet/issues/new).
- Join our [community meetings](https://hackmd.io/@racklet/Sk8jHHc7_) (see also the [meeting-notes](https://github.com/racklet/meeting-notes) repo).

Your feedback is always welcome!

## Maintainers

In alphabetical order:

- Dennis Marttinen, [@twelho](https://github.com/twelho)
- Jaakko Sirén, [@Jaakkonen](https://github.com/Jaakkonen)
- Lucas Käldström, [@luxas](https://github.com/luxas)
- Verneri Hirvonen, [@chiplet](https://github.com/chiplet)

## License

[Apache 2.0](LICENSE)
