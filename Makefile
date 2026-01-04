# VibeFetch Makefile
# Comprehensive build system for cross-platform compilation

# Compiler settings
CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wextra -O2 -Wno-unused-parameter -Wno-unused-variable -Wno-missing-field-initializers -Wno-multichar
DEBUGFLAGS = -g -DDEBUG

# Target executable
TARGET = VibeFetch
ifeq ($(OS),Windows_NT)
    TARGET := $(TARGET).exe
endif

# Source files
SOURCES = VibeFetch.cpp
OBJECTS = $(SOURCES:.cpp=.o)

# Platform detection
UNAME_S := $(shell uname -s 2>/dev/null || echo Windows)

# Platform-specific flags
ifeq ($(UNAME_S),Linux)
    CXXFLAGS += -D__linux__
    LDFLAGS =
endif
ifeq ($(UNAME_S),Darwin)
    CXXFLAGS += -D__APPLE__
    LDFLAGS =
endif
ifeq ($(OS),Windows_NT)
    CXXFLAGS += -D_WIN32
    LDFLAGS = -lws2_32
endif

# Build rules
.PHONY: all clean run run-debug install uninstall help test benchmark check-syntax format

# Default target
all: $(TARGET)
	@echo "==================================="
	@echo "VibeFetch compiled successfully!"
	@echo "Run with: make run"
	@echo "Or directly: ./$(TARGET)"
	@echo "==================================="

# Compile the executable
$(TARGET): $(OBJECTS)
	@echo "Linking $(TARGET)..."
	@$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJECTS) $(LDFLAGS)

# Compile object files
%.o: %.cpp
	@echo "Compiling $<..."
	@$(CXX) $(CXXFLAGS) -c $< -o $@ 2>/dev/null || $(CXX) $(CXXFLAGS) -c $< -o $@

# Run the program
run: $(TARGET)
	@echo "Running VibeFetch..."
	@./$(TARGET) 2>&1 | grep -v "lspci: not found"

# Run with debug mode for specific distro
# Usage: make run-debug distro=Ubuntu
# Note: For Pop!_OS, use: make run-debug distro='Pop!_OS' (with single quotes)
run-debug: $(TARGET)
ifndef distro
	@echo "Error: Please specify distro. Example: make run-debug distro=Ubuntu"
	@echo ""
	@echo "Supported distros:"
	@echo "  Linux: Ubuntu, Debian, Kali, Arch, Mint, RHEL, Fedora, Gentoo, Pop!_OS, Zorin"
	@echo "  Windows: Windows XP, Windows Vista, Windows 7, Windows 8, Windows 10, Windows 11"
	@echo "  macOS: macOS Big Sur, macOS Monterey, macOS Ventura, macOS Sonoma, macOS Sequoia, macOS 26"
	@echo ""
	@echo "Special note: For Pop!_OS, use single quotes: make run-debug distro='Pop!_OS'"
	@exit 1
else
	@echo "Running VibeFetch in debug mode for $(distro)..."
	@./$(TARGET) --debug "$(distro)"
endif

# Install to system (Linux/macOS)
install: $(TARGET)
	@echo "Installing VibeFetch..."
ifeq ($(UNAME_S),Linux)
	sudo install -m 755 $(TARGET) /usr/local/bin/vibefetch
	@echo "VibeFetch installed to /usr/local/bin/vibefetch"
else ifeq ($(UNAME_S),Darwin)
	sudo install -m 755 $(TARGET) /usr/local/bin/vibefetch
	@echo "VibeFetch installed to /usr/local/bin/vibefetch"
else
	@echo "Install target not supported on Windows. Copy $(TARGET) to your PATH manually."
endif

# Uninstall from system
uninstall:
	@echo "Uninstalling VibeFetch..."
ifeq ($(UNAME_S),Linux)
	sudo rm -f /usr/local/bin/vibefetch
	@echo "VibeFetch uninstalled"
else ifeq ($(UNAME_S),Darwin)
	sudo rm -f /usr/local/bin/vibefetch
	@echo "VibeFetch uninstalled"
else
	@echo "Uninstall target not supported on Windows."
endif

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -f $(OBJECTS) $(TARGET)
	@echo "Clean complete"

# Help message
help:
	@echo "VibeFetch Makefile"
	@echo "=================="
	@echo ""
	@echo "Available targets:"
	@echo "  make all              - Build VibeFetch (default)"
	@echo "  make run              - Build and run VibeFetch"
	@echo "  make run-debug distro=<OS> - Run with specific OS display"
	@echo "  make clean            - Remove build artifacts"
	@echo "  make install          - Install to system (requires sudo)"
	@echo "  make uninstall        - Remove from system (requires sudo)"
	@echo "  make help             - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make                          # Build VibeFetch"
	@echo "  make run                      # Build and run"
	@echo "  make run-debug distro=Ubuntu  # Show Ubuntu display"
	@echo "  make run-debug distro='Pop!_OS'  # Show Pop!_OS display (use single quotes)"
	@echo "  make run-debug distro=\\\"Windows 11\\\"  # Show Windows 11 display"
	@echo "  make clean                    # Clean build"
	@echo ""
	@echo "Supported OS for debug mode:"
	@echo "  Ubuntu, Debian, Kali, Arch, Mint, RHEL, Fedora, Gentoo,"
	@echo "  Pop!_OS, Zorin, Windows XP, Windows Vista, Windows 7,"
	@echo "  Windows 8, Windows 10, Windows 11, macOS Big Sur,"
	@echo "  macOS Monterey, macOS Ventura, macOS Sonoma, macOS Sequoia"
	@echo ""

# Version info
version:
	@echo "VibeFetch v2.0.0"
	@echo "System Information Tool with Configuration Support"
	@echo "Copyright (c) 2026"

# Compile with debug symbols
debug: CXXFLAGS += $(DEBUGFLAGS)
debug: clean $(TARGET)
	@echo "Debug build complete"

# Run tests
test: $(TARGET)
	@echo "Running VibeFetch tests..."
	@./$(TARGET) --debug Ubuntu
	@./$(TARGET) --debug "Windows 11"
	@./$(TARGET) --debug "macOS Ventura"
	@echo "All tests passed!"

# Benchmark mode
benchmark: $(TARGET)
	@echo "Running VibeFetch benchmark..."
	@time ./$(TARGET) > /dev/null

# Check syntax without building
check-syntax:
	@echo "Checking C++ syntax..."
	$(CXX) $(CXXFLAGS) -fsyntax-only $(SOURCES)
	@echo "Syntax check passed!"

# Format code (if clang-format is available)
format:
	@if command -v clang-format >/dev/null 2>&1; then \
		echo "Formatting code..."; \
		clang-format -i $(SOURCES); \
		echo "Code formatted!"; \
	else \
		echo "clang-format not found. Install it to use this target."; \
	fi

# Static analysis (if cppcheck is available)
analyze:
	@if command -v cppcheck >/dev/null 2>&1; then \
		echo "Running static analysis..."; \
		cppcheck --enable=all --suppress=missingIncludeSystem $(SOURCES); \
	else \
		echo "cppcheck not found. Install it to use this target."; \
	fi

# Create release package
package: clean all
	@echo "Creating release package..."
	@mkdir -p vibefetch-release
	@cp $(TARGET) vibefetch-release/
	@cp README.md vibefetch-release/
	@cp Makefile vibefetch-release/
	@tar -czf vibefetch-release.tar.gz vibefetch-release/
	@rm -rf vibefetch-release
	@echo "Release package created: vibefetch-release.tar.gz"
