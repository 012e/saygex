# Hello world

Ah got it — you want to **embed an external binary into your Go program** (so it ships as a single binary), and then **execute it at runtime**. Yes, that's totally possible using `embed` and writing the binary to a temporary file. Here's how:

### ✅ Step-by-step: Embed and run a binary in Go

#### 1. Embed the binary file

```go
import (
	"embed"
	"os"
	"os/exec"
	"path/filepath"
)

//go:embed mybinary
var embeddedBinary []byte
```

> 🔸 Make sure the binary is marked as executable (`chmod +x mybinary`), and don't forget to exclude it from source control if needed (`.gitignore`).

---

#### 2. Write the binary to a temp file at runtime

```go
func writeTempBinary(data []byte, name string) (string, error) {
	tmpDir := os.TempDir()
	tmpPath := filepath.Join(tmpDir, name)

	if err := os.WriteFile(tmpPath, data, 0755); err != nil {
		return "", err
	}
	return tmpPath, nil
}
```

---

#### 3. Run the embedded binary

```go
func main() {
	binPath, err := writeTempBinary(embeddedBinary, "mybinary")
	if err != nil {
		panic(err)
	}

	cmd := exec.Command(binPath, "--some", "args")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		panic(err)
	}
}
```

---

### ✅ Final notes

- This works cross-platform as long as you embed the correct binary per OS/arch.
- You can conditionally embed multiple binaries using `//go:build`.
- The embedded binary is fully included in the final Go binary — so it's self-contained.
- Use `0755` permission to make it executable.

Let me know if you want to embed different binaries per OS (like `mytool-linux`, `mytool-windows.exe`, etc.), I can show you a nice setup for that too.