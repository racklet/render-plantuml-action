package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/racklet/render-drawio-action/pkg/render"
)

func main() {
	if err := run(); err != nil {
		fmt.Printf("error occurred: %v\n", err)
		os.Exit(1)
	}
}

func run() error {
	// Setup default config
	cfg := &render.Config{
		RootDir:  "/files",
		SubDirs:  []string{"."},
		SkipDirs: []string{".git"},

		Files: map[string]string{},

		SrcFormats:       []string{"plantuml", "puml"},
		ValidSrcFormats:  []string{"plantuml", "puml"},
		DestFormats:      []string{"svg"},
		ValidDestFormats: []string{"png", "svg"},
	}

	// Unconditionally overwrite root path if GH Action workspace is set
	if ghWorkspace := os.Getenv("GITHUB_WORKSPACE"); len(ghWorkspace) != 0 {
		cfg.RootDir = ghWorkspace
	}

	// Validate and complete the config with info from the environment
	if err := cfg.Complete(render.DefaultFlags); err != nil {
		return err
	}

	// Make outputFiles as large as there are files
	outputFiles := make([]string, 0, len(cfg.Files))

	// Render the files using the plantuml CLI
	err := cfg.Render(func(src, dest string) error {
		ctx := context.Background()

		srcFile, err := os.Open(src)
		if err != nil {
			return err
		}
		defer srcFile.Close()

		destFile, err := os.Create(dest)
		if err != nil {
			return err
		}
		defer destFile.Close()

		format := render.ExtToFormat(filepath.Ext(dest))
		out, _, err := render.ShellCommand(ctx, "java -Djava.awt.headless=true -jar /plantuml.jar -p -t%s", format).
			WithStdio(srcFile, destFile, nil).Run()
		if err != nil {
			return fmt.Errorf("failed to run plantuml for src=%q and dest=%q: %v, output: %s", src, dest, err, string(out))
		}

		// The output file does not include the root directory prefix
		outputFiles = append(outputFiles, dest)

		return nil
	})
	if err != nil {
		return err
	}

	// Set the GH Action output
	render.GitHubActionSetOutput("rendered-files", strings.Join(outputFiles, " "))

	return nil
}
