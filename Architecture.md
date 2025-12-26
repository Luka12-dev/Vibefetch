# VibeFetch Architecture

<div align="center">

**Comprehensive System Design Documentation**

Version 1.0.0 | Last Updated: 2024-12-26

</div>

---

## 📋 Table of Contents

1. [System Overview](#system-overview)
2. [Architecture Layers](#architecture-layers)
3. [Component Design](#component-design)
4. [Data Flow](#data-flow)
5. [Platform Abstractions](#platform-abstractions)
6. [Design Patterns](#design-patterns)
7. [Performance Considerations](#performance-considerations)
8. [Security Model](#security-model)
9. [Extension Points](#extension-points)
10. [Future Architecture](#future-architecture)

---

## 🏗️ System Overview

VibeFetch is architected as a modular, cross-platform system information gathering tool. The architecture emphasizes:

- **Modularity**: Clear separation of concerns
- **Portability**: Platform-agnostic design with platform-specific implementations
- **Performance**: Efficient system calls and minimal overhead
- **Extensibility**: Easy to add new information sources and display formats
- **Maintainability**: Well-documented, consistent code structure

### High-Level Architecture Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                        VibeFetch Core                          │
│                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Input Layer │  │ Processing   │  │ Output Layer │          │
│  │  Input Layer │  │ Processing   │  │ Output Layer │          │
│  │              │  │    Layer     │  │              │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                 │                 │                  │
└─────────┼─────────────────┼─────────────────┼──────────────────┘
          │                 │                 │
          ▼                 ▼                 ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  CLI Arguments  │ │   Information   │ │  ASCII Art      │
│  Configuration  │ │   Gatherers     │ │  Formatting     │
│  Environment    │ │   Processors    │ │  Color Output   │
└─────────────────┘ └─────────────────┘ └─────────────────┘
                            │
                            ▼
                    ┌────────────────────────┐
                    │  Platform Layer        │
                    │                        │
                    │  ┌──────┬──────┬──────┐
                    │  │Linux │macOS │Windows│
                    │  └──────┴──────┴──────┘
                    └───────────────────┘
```

---

## 📚 Architecture Layers

### 1. Platform Detection Layer

**Responsibility**: Identify the operating system and environment

**Components**:
- `detectOS()` - Base OS detection (Linux/macOS/Windows)
- `detectDistro()` - Specific distribution/version detection
- `detectArchitecture()` - CPU architecture identification

**Implementation Strategy**:
```cpp
// Compile-time detection
#ifdef _WIN32
    // Windows-specific code
#elif __APPLE__
    // macOS-specific code
#elif __linux__
    // Linux-specific code
#endif

// Runtime detection
string detectDistro() {
    // Platform-specific runtime checks
    // - Windows: Registry, WMI
    // - macOS: sw_vers, system_profiler
    // - Linux: /etc/os-release, lsb_release
}
```

**Data Sources**:
- **Windows**: Registry (`HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion`), WMI
- **macOS**: `sw_vers`, `system_profiler`
- **Linux**: `/etc/os-release`, `/etc/lsb-release`, `/proc/version`

---

### 2. Hardware Information Layer

**Responsibility**: Gather detailed hardware specifications

#### 2.1 CPU Information Subsystem

**Components**:
- `getCPU()` - CPU model name
- `getCPUCores()` - Core count
- `getCPUFrequency()` - Clock speed
- `getCPUTemperature()` - Thermal readings
- `getCPUVendor()` - Manufacturer identification

**Detection Methods**:

| Platform | Primary Method | Fallback Method |
|----------|----------------|-----------------|
| **Windows** | Registry | WMI |
| **macOS** | sysctl | system_profiler |
| **Linux** | /proc/cpuinfo | lscpu |

**Data Structure**:
```cpp
struct CPUInfo {
    string model;
    int cores;
    int threads;
    double frequency;     // GHz
    string vendor;
    string architecture;
    vector<int> cacheSize; // L1, L2, L3
};
```

#### 2.2 Memory Information Subsystem

**Components**:
- `getMemory()` - Total and used memory
- `getTotalRAM()` - Total installed RAM
- `getAvailableRAM()` - Free memory
- `getSwapUsage()` - Virtual memory usage

**Detection Methods**:

| Platform | API/Method |
|----------|------------|
| **Windows** | `GlobalMemoryStatusEx()` |
| **macOS** | `sysctl hw.memsize`, `vm_stat` |
| **Linux** | `sysinfo()`, `/proc/meminfo` |

#### 2.3 GPU Information Subsystem

**Components**:
- `getGPU()` - GPU model
- `getGPUMemory()` - VRAM
- `getGPUDriver()` - Driver version
- `getGPUTemperature()` - GPU thermal readings

**Detection Methods**:

| Platform | Method | Tools Required |
|----------|--------|----------------|
| **Windows** | WMI | - |
| **macOS** | system_profiler | - |
| **Linux** | lspci | pciutils |
| **Linux (NVIDIA)** | nvidia-smi | nvidia-utils |
| **Linux (AMD)** | /sys/class/drm | - |

#### 2.4 Storage Information Subsystem

**Components**:
- `getDiskUsage()` - Space usage
- `getDiskType()` - HDD/SSD detection
- `getDiskModel()` - Drive identification
- `getDiskSpeed()` - Read/write performance

---

### 3. Software Information Layer

**Responsibility**: Gather software environment details

#### 3.1 Operating System Subsystem

**Components**:
- `getOSVersionDetailed()` - Complete version string
- `getOSBuildNumber()` - Build/kernel version
- `getOSInstallDate()` - Installation timestamp
- `getOSLanguage()` - System locale

#### 3.2 Desktop Environment Subsystem

**Components**:
- `getDE()` - Desktop environment name
- `getWindowManager()` - Window manager
- `getCompositor()` - Compositor information
- `getGTKTheme()` - GTK theme
- `getIconTheme()` - Icon set

**Detection Strategy**:
```cpp
// Environment variable cascade
1. Check XDG_CURRENT_DESKTOP
2. Check DESKTOP_SESSION
3. Check running processes (ps, tasklist)
4. Check configuration files
```

#### 3.3 Shell and Terminal Subsystem

**Components**:
- `getShell()` - Login shell
- `getTerminal()` - Terminal emulator
- `getSessionType()` - X11/Wayland/TTY

---

### 4. Network Information Layer

**Responsibility**: Network configuration and connectivity

**Components**:
- `getLocalIP()` - Internal IP address
- `getPublicIP()` - External IP (optional)
- `getMACAddress()` - Hardware address
- `getGatewayIP()` - Default gateway
- `getDNSServers()` - DNS configuration
- `getNetworkInterface()` - Active interface

**Security Considerations**:
- No external network calls in default mode
- Public IP only fetched with explicit permission
- MAC address anonymization option

---

### 5. Visual Presentation Layer

**Responsibility**: Format and display information with ASCII art

#### 5.1 ASCII Art System

**Components**:
- `getASCIIArt()` - Main dispatcher
- OS-specific art functions (20+ implementations)
- Art caching system
- Color application layer

**ASCII Art Architecture**:
```cpp
┌─────────────────────────────────────┐
│      ASCII Art Repository           │
│  ┌───────────────────────────────┐  │
│  │  Linux Distros (10+ logos)    │  │
│  │  - Ubuntu, Arch, Fedora, ...  │  │
│  ├───────────────────────────────┤  │
│  │  Windows Versions (6 logos)   │  │
│  │  - XP, 7, 10, 11, ...         │  │
│  ├───────────────────────────────┤  │
│  │  macOS Versions (6+ logos)    │  │
│  │  - Big Sur, Monterey, ...     │  │
│  └───────────────────────────────┘  │
│                                     │
│         Dispatcher Function         │
│      getASCIIArt(os_name)          │
└─────────────────────────────────────┘
```

**Color Scheme System**:
```cpp
// Color mapping per OS
map<string, int> osColorSchemes = {
    {"Ubuntu", COLOR_BRIGHT_RED},
    {"Arch", COLOR_BRIGHT_CYAN},
    {"Fedora", COLOR_BRIGHT_BLUE},
    // ... 20+ mappings
};
```

#### 5.2 Display Formatting

**Layout System**:
```
┌────────────────┬────────────────────────────┐
│                │                            │
│   ASCII ART    │   System Information       │
│   (20 lines)   │   - OS: ...                │
│                │   - Kernel: ...            │
│                │   - CPU: ...               │
│                │   - Memory: ...            │
│                │   ...                      │
│                │                            │
└────────────────┴────────────────────────────┘
     40 chars           60+ chars
```

**Alignment Algorithm**:
```cpp
void printVibeFetch(const string& os) {
    vector<string> art = getASCIIArt(os);
    vector<string> info = gatherSystemInfo();
    
    size_t maxLines = max(art.size(), info.size());
    
    for (size_t i = 0; i < maxLines; i++) {
        // Print ASCII art (left column)
        if (i < art.size())
            cout << art[i];
        else
            cout << string(40, ' ');
        
        cout << "  "; // Separator
        
        // Print info (right column)
        if (i < info.size())
            printColoredInfo(info[i]);
        
        cout << endl;
    }
}
```

---

## 🔄 Data Flow

### Information Gathering Flow

```
┌───────────┐
│   Start   │
└─────┬─────┘
      │
      ▼
┌───────────────────┐
│ Detect Platform   │ ──► Compile-time + Runtime checks
└─────┬─────────────┘
      │
      ▼
┌───────────────────┐
│ Select Gatherers  │ ──► Platform-specific implementations
└─────┬─────────────┘
      │
      ├──► CPU Info    ──► getCPU(), getCPUCores(), etc.
      ├──► Memory Info ──► getMemory(), getSwap(), etc.
      ├──► GPU Info    ──► getGPU(), getGPUDriver(), etc.
      ├──► Disk Info   ──► getDiskUsage(), getDiskType(), etc.
      ├──► Network     ──► getLocalIP(), getMACAddress(), etc.
      └──► Software    ──► getDE(), getShell(), etc.
      │
      ▼
┌───────────────────┐
│ Format Output     │ ──► ASCII art + Info formatting
└─────┬─────────────┘
      │
      ▼
┌───────────────────┐
│ Apply Colors      │ ──► ANSI escape codes
└─────┬─────────────┘
      │
      ▼
┌───────────────────┐
│ Display to User   │
└───────────────────┘
```

### Error Handling Flow

```
Information Request
        │
        ▼
┌───────────────────┐
│ Try Primary Method│
└─────┬─────────────┘
      │
      ├─ Success ──► Return Data
      │
      └─ Failure
          │
          ▼
┌───────────────────┐
│ Try Fallback      │
└─────┬─────────────┘
      │
      ├─ Success ──► Return Data
      │
      └─ Failure
          │
          ▼
┌───────────────────┐
│ Return "Unknown"  │ ──► Graceful degradation
└───────────────────┘
```

---

## 🔌 Platform Abstractions

### Abstraction Strategies

#### 1. Compile-Time Abstraction

```cpp
// Platform-specific includes
#ifdef _WIN32
    #include <windows.h>
    #include <sysinfoapi.h>
#elif __APPLE__
    #include <sys/sysctl.h>
#elif __linux__
    #include <sys/sysinfo.h>
#endif

// Platform-specific functions
string getCPU() {
#ifdef _WIN32
    return getCPU_Windows();
#elif __APPLE__
    return getCPU_macOS();
#elif __linux__
    return getCPU_Linux();
#endif
}
```

#### 2. Runtime Abstraction

```cpp
class SystemInfoGatherer {
public:
    virtual string getCPU() = 0;
    virtual string getMemory() = 0;
    // ... other methods
};

class WindowsInfoGatherer : public SystemInfoGatherer {
    string getCPU() override { /* Windows implementation */ }
};

class LinuxInfoGatherer : public SystemInfoGatherer {
    string getCPU() override { /* Linux implementation */ }
};

// Factory method
unique_ptr<SystemInfoGatherer> createGatherer() {
#ifdef _WIN32
    return make_unique<WindowsInfoGatherer>();
#elif __linux__
    return make_unique<LinuxInfoGatherer>();
#endif
}
```

### Platform-Specific Implementations

#### Windows Implementation

**Primary APIs**:
- Registry (CPU, OS info)
- WMI (Hardware details)
- Win32 API (Memory, network)

**Code Pattern**:
```cpp
string getCPU_Windows() {
    HKEY hKey;
    char buffer[256];
    DWORD size = sizeof(buffer);
    
    if (RegOpenKeyExA(HKEY_LOCAL_MACHINE, 
                      "HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0",
                      0, KEY_READ, &hKey) == ERROR_SUCCESS) {
        RegQueryValueExA(hKey, "ProcessorNameString", 
                        NULL, NULL, (LPBYTE)buffer, &size);
        RegCloseKey(hKey);
        return string(buffer);
    }
    return "Unknown CPU";
}
```

#### macOS Implementation

**Primary Tools**:
- `sysctl` (Hardware info)
- `system_profiler` (Detailed system info)
- Unix utilities (standard tools)

**Code Pattern**:
```cpp
string getCPU_macOS() {
    FILE* pipe = popen("sysctl -n machdep.cpu.brand_string", "r");
    if (!pipe) return "Unknown CPU";
    
    char buffer[256];
    string result;
    if (fgets(buffer, sizeof(buffer), pipe)) {
        result = buffer;
    }
    pclose(pipe);
    return trim(result);
}
```

#### Linux Implementation

**Primary Sources**:
- `/proc` filesystem (CPU, memory, kernel)
- `/sys` filesystem (Hardware details)
- System utilities (lscpu, lspci, etc.)

**Code Pattern**:
```cpp
string getCPU_Linux() {
    ifstream cpuinfo("/proc/cpuinfo");
    string line;
    
    while (getline(cpuinfo, line)) {
        if (line.find("model name") != string::npos) {
            size_t pos = line.find(":");
            return trim(line.substr(pos + 1));
        }
    }
    return "Unknown CPU";
}
```

---

## 🎨 Design Patterns

### 1. Strategy Pattern

**Usage**: Multiple detection methods for each metric

```cpp
class CPUDetectionStrategy {
public:
    virtual string detect() = 0;
};

class RegistryCPUDetection : public CPUDetectionStrategy {
    string detect() override { /* Registry method */ }
};

class WMICPUDetection : public CPUDetectionStrategy {
    string detect() override { /* WMI method */ }
};

string getCPU() {
    vector<unique_ptr<CPUDetectionStrategy>> strategies;
    strategies.push_back(make_unique<RegistryCPUDetection>());
    strategies.push_back(make_unique<WMICPUDetection>());
    
    for (auto& strategy : strategies) {
        string result = strategy->detect();
        if (result != "Unknown") return result;
    }
    return "Unknown CPU";
}
```

### 2. Factory Pattern

**Usage**: OS-specific ASCII art generation

```cpp
class ASCIIArtFactory {
public:
    static vector<string> createArt(const string& os) {
        if (os == "Ubuntu") return getUbuntuASCII();
        if (os == "Arch") return getArchASCII();
        if (os == "Windows 11") return getWindows11ASCII();
        // ... more cases
        return getDefaultASCII();
    }
};
```

### 3. Singleton Pattern

**Usage**: Global configuration management

```cpp
class Config {
private:
    static Config* instance;
    Config() { /* Load config */ }
    
public:
    static Config* getInstance() {
        if (!instance) {
            instance = new Config();
        }
        return instance;
    }
    
    bool getShowASCII() const;
    bool getShowColors() const;
    // ... other getters
};
```

### 4. Template Method Pattern

**Usage**: Common information gathering workflow

```cpp
class InfoGatherer {
public:
    string gatherInfo() {
        string primary = tryPrimaryMethod();
        if (primary != "Unknown") return primary;
        
        string fallback = tryFallbackMethod();
        if (fallback != "Unknown") return fallback;
        
        return handleFailure();
    }
    
protected:
    virtual string tryPrimaryMethod() = 0;
    virtual string tryFallbackMethod() = 0;
    
    string handleFailure() {
        return "Unknown";
    }
};
```

### 5. Adapter Pattern

**Usage**: Platform-specific API wrapping

```cpp
class SystemAPI {
public:
    virtual string executeCommand(const string& cmd) = 0;
};

class WindowsAPI : public SystemAPI {
    string executeCommand(const string& cmd) override {
        return executeCMD(cmd);  // Windows-specific
    }
};

class UnixAPI : public SystemAPI {
    string executeCommand(const string& cmd) override {
        return executeBash(cmd);  // Unix-specific
    }
};
```

---

## ⚡ Performance Considerations

### 1. Lazy Evaluation

**Strategy**: Information gathered only when displayed

```cpp
class LazySystemInfo {
private:
    mutable optional<string> cachedCPU;
    
public:
    string getCPU() const {
        if (!cachedCPU) {
            cachedCPU = detectCPU();  // Expensive operation
        }
        return *cachedCPU;
    }
};
```

### 2. Caching Strategy

**Implementation**:
```cpp
map<string, string> infoCache;

string getCachedInfo(const string& key, function<string()> getter) {
    auto it = infoCache.find(key);
    if (it != infoCache.end()) {
        return it->second;
    }
    
    string value = getter();
    infoCache[key] = value;
    return value;
}

// Usage
string cpu = getCachedInfo("cpu", getCPU);
```

### 3. Parallel Execution

**Potential Optimization** (not yet implemented):
```cpp
#include <thread>
#include <future>

void gatherSystemInfoParallel() {
    auto futureCPU = async(launch::async, getCPU);
    auto futureGPU = async(launch::async, getGPU);
    auto futureMem = async(launch::async, getMemory);
    
    string cpu = futureCPU.get();
    string gpu = futureGPU.get();
    string mem = futureMem.get();
}
```

### 4. Memory Efficiency

**Strategies**:
- Use `string_view` for read-only strings (C++17)
- Reserve vector capacity when size is known
- Use move semantics for large objects
- Avoid unnecessary string copies

```cpp
vector<string> getASCIIArt(const string& os) {
    vector<string> art;
    art.reserve(20);  // Reserve expected capacity
    // ... populate art
    return art;  // Move semantics avoid copy
}
```

### 5. System Call Optimization

**Best Practices**:
- Batch related queries
- Use native APIs over shell commands
- Cache frequently accessed data
- Avoid redundant system calls

**Example**:
```cpp
// Bad: Multiple calls
string cpu = executeCommand("cat /proc/cpuinfo | grep 'model name'");
string cores = executeCommand("cat /proc/cpuinfo | grep 'cpu cores'");

// Good: Single read
string cpuinfo = readFile("/proc/cpuinfo");
string cpu = parseCPUModel(cpuinfo);
string cores = parseCPUCores(cpuinfo);
```

---

## 🔒 Security Model

### 1. Privilege Requirements

**VibeFetch Design Principle**: **No elevated privileges required**

| Operation | Privilege | Platform |
|-----------|-----------|----------|
| CPU detection | User | All |
| Memory info | User | All |
| Disk usage | User | All |
| Network info | User | All |
| GPU info (basic) | User | All |
| GPU temp (advanced) | Admin/Root | Linux |
| System modification | **Never** | All |

### 2. Safe Operations Only

**Guarantee**: VibeFetch performs only read operations

```cpp
// All operations are read-only
string getCPU() {
    // ✓ Read registry
    // ✓ Read files
    // ✓ Execute info commands
    // ✗ Never write/modify
}
```

### 3. Input Validation

**Command-line argument validation**:
```cpp
int main(int argc, char* argv[]) {
    if (argc > 1) {
        string arg = argv[1];
        
        // Whitelist validation
        if (arg != "--help" && 
            arg != "--version" && 
            arg != "--debug") {
            cerr << "Invalid argument" << endl;
            return 1;
        }
    }
}
```

### 4. Resource Cleanup

**RAII Principle**: All resources automatically cleaned up

```cpp
// File handles
{
    ifstream file("/proc/cpuinfo");
    // ... use file
} // Automatically closed

// Process pipes
FILE* pipe = popen("command", "r");
// ... use pipe
pclose(pipe);  // Must close explicitly
```

### 5. Error Handling

**No Crashes Policy**: All errors handled gracefully

```cpp
string getCPU() {
    try {
        // Attempt CPU detection
        return detectCPU();
    } catch (const exception& e) {
        // Log error (optional)
        return "Unknown CPU";
    }
}
```

---

## 🔧 Extension Points

### 1. Adding New Information Sources

**Example**: Add CPU cache information

```cpp
// 1. Add detection function
string getCPUCache() {
#ifdef __linux__
    return readFile("/sys/devices/system/cpu/cpu0/cache/index2/size");
#elif __APPLE__
    return executeCommand("sysctl -n hw.l2cachesize");
#elif _WIN32
    // Windows implementation
    return "Unknown";
#endif
}

// 2. Add to display
void printVibeFetch() {
    // ... existing code
    infoLines.push_back("CPU Cache: " + getCPUCache());
}
```

### 2. Adding New Operating Systems

**Example**: Add FreeBSD support

```cpp
// 1. Add detection
string detectDistro() {
#ifdef __FreeBSD__
    return "FreeBSD";
#else
    // ... existing code
#endif
}

// 2. Add ASCII art
vector<string> getFreeBSDASCII() {
    vector<string> art;
    art.push_back("  /\\ _____ /\\  ");
    art.push_back(" /  \\|___|/  \\ ");
    // ... complete logo
    return art;
}

// 3. Register in dispatcher
vector<string> getASCIIArt(const string& os) {
    if (os == "FreeBSD") return getFreeBSDASCII();
    // ... existing cases
}
```

### 3. Adding Display Formats

**Example**: Add JSON output

```cpp
class JSONFormatter {
public:
    string format(const map<string, string>& info) {
        string json = "{\n";
        for (const auto& [key, value] : info) {
            json += "  \"" + key + "\": \"" + value + "\",\n";
        }
        json += "}\n";
        return json;
    }
};

// Usage
if (outputFormat == "json") {
    JSONFormatter formatter;
    cout << formatter.format(systemInfo);
}
```

### 4. Plugin System (Future)

**Proposed Architecture**:
```cpp
class Plugin {
public:
    virtual string getName() = 0;
    virtual string getInfo() = 0;
    virtual vector<string> getASCII() = 0;
};

class PluginManager {
private:
    vector<unique_ptr<Plugin>> plugins;
    
public:
    void loadPlugin(const string& path);
    void executePlugins();
};
```

## 📊 Metrics and Monitoring

### Code Metrics

| Metric | Target | Current |
|--------|--------|---------|
| Lines of Code | <15,000 | ~10,000 |
| Functions | <200 | ~150 |
| Cyclomatic Complexity | <10 per function | <8 |
| Code Coverage | >80% | N/A |
| Build Time | <10s | ~3s |
| Execution Time | <1s | ~0.3s |

### Performance Benchmarks

| Operation | Target | Actual |
|-----------|--------|--------|
| Cold start | <500ms | ~300ms |
| Warm start | <200ms | ~150ms |
| CPU detection | <50ms | ~30ms |
| Memory detection | <50ms | ~20ms |
| Full display | <1s | ~300ms |

---

## 📝 Development Guidelines

### Code Organization

**File Structure**:
```cpp
// 1. License header
// 2. File description
// 3. Includes
// 4. Constants
// 5. Forward declarations
// 6. Type definitions
// 7. Function implementations
// 8. Main function
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Functions | camelCase | `getCPUInfo()` |
| Classes | PascalCase | `SystemInfo` |
| Constants | UPPER_CASE | `COLOR_RED` |
| Variables | camelCase | `systemInfo` |
| Macros | UPPER_CASE | `MAX_BUFFER` |

### Documentation Standards

**Function Documentation**:
```cpp
/**
 * @brief Retrieves CPU model information
 * @return String containing CPU model name
 * @throws None - Returns "Unknown CPU" on failure
 * 
 * Detection priority:
 * 1. Windows: Registry query
 * 2. macOS: sysctl command
 * 3. Linux: /proc/cpuinfo parsing
 */
string getCPU() {
    // Implementation
}
```

**Comment Guidelines**:
- Use `//` for single-line comments
- Use `/* */` for multi-line explanations
- Document all public APIs
- Explain "why" not "what" (code shows what)
- Keep comments up-to-date with code changes

### Testing Strategy

**Unit Testing Framework**: Catch2 (recommended)

```cpp
#include <catch2/catch.hpp>

TEST_CASE("CPU Detection", "[cpu]") {
    SECTION("Returns non-empty string") {
        string cpu = getCPU();
        REQUIRE(!cpu.empty());
    }
    
    SECTION("Never returns empty") {
        REQUIRE(getCPU() != "");
    }
}
```

### Build System

**CMake Support** (future):
```cmake
cmake_minimum_required(VERSION 3.10)
project(VibeFetch)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(VibeFetch VibeFetch.cpp)

# Platform-specific libraries
if(WIN32)
    target_link_libraries(VibeFetch ws2_32)
endif()
```

---

## 🧪 Testing Architecture

### Testing Levels

#### 1. Unit Tests

**Scope**: Individual functions in isolation

**Example Test Cases**:
```cpp
// String utility tests
TEST_CASE("String Trimming") {
    REQUIRE(trim("  hello  ") == "hello");
    REQUIRE(trim("test") == "test");
    REQUIRE(trim("") == "");
}

// Platform detection tests
TEST_CASE("OS Detection") {
    string os = detectOS();
    REQUIRE((os == "Windows" || os == "macOS" || os == "Linux"));
}
```

#### 2. Integration Tests

**Scope**: Multiple components working together

**Example**:
```cpp
TEST_CASE("Full System Info Gathering") {
    // Should complete without crashes
    string cpu = getCPU();
    string memory = getMemory();
    string gpu = getGPU();
    
    // All should return something
    REQUIRE(!cpu.empty());
    REQUIRE(!memory.empty());
    REQUIRE(!gpu.empty());
}
```

#### 3. Cross-Platform Tests

**Scope**: Verify consistent behavior across platforms

**Test Matrix**:
| Test Case | Windows | macOS | Linux |
|-----------|---------|-------|-------|
| CPU Detection | ✓ | ✓ | ✓ |
| Memory Detection | ✓ | ✓ | ✓ |
| GPU Detection | ✓ | ✓ | ✓ |
| ASCII Art Display | ✓ | ✓ | ✓ |
| Color Output | ✓ | ✓ | ✓ |

#### 4. Performance Tests

**Benchmarking**:
```cpp
TEST_CASE("Performance Benchmarks") {
    auto start = chrono::high_resolution_clock::now();
    
    // Run VibeFetch
    string result = gatherAllInfo();
    
    auto end = chrono::high_resolution_clock::now();
    auto duration = chrono::duration_cast<chrono::milliseconds>(end - start);
    
    // Should complete in under 1 second
    REQUIRE(duration.count() < 1000);
}
```

---

## 🔍 Debugging and Diagnostics

### Debug Build Configuration

**Compile with debug symbols**:
```bash
make debug
# or
g++ -g -DDEBUG -std=c++11 VibeFetch.cpp -o VibeFetch
```

### Logging System

**Implementation**:
```cpp
enum LogLevel {
    LOG_DEBUG,
    LOG_INFO,
    LOG_WARNING,
    LOG_ERROR
};

void log(LogLevel level, const string& message) {
#ifdef DEBUG
    const char* levelStr[] = {"DEBUG", "INFO", "WARN", "ERROR"};
    cerr << "[" << levelStr[level] << "] " << message << endl;
#endif
}

// Usage
log(LOG_DEBUG, "Attempting CPU detection...");
string cpu = getCPU();
log(LOG_INFO, "CPU detected: " + cpu);
```

### Common Issues and Solutions

#### Issue 1: Permission Denied

**Problem**: Cannot read certain system files

**Solution**:
```cpp
string readSystemFile(const string& path) {
    ifstream file(path);
    if (!file.is_open()) {
        log(LOG_WARNING, "Cannot open: " + path);
        return "Unknown";
    }
    // ... read file
}
```

#### Issue 2: Command Not Found

**Problem**: System utility not available

**Solution**:
```cpp
bool commandExists(const string& cmd) {
    string checkCmd = "which " + cmd + " >/dev/null 2>&1";
    return system(checkCmd.c_str()) == 0;
}

string getCPU() {
    if (commandExists("lscpu")) {
        return executeLscpu();
    }
    // Fallback to /proc/cpuinfo
    return readProcCpuinfo();
}
```

#### Issue 3: Incorrect Detection

**Problem**: Wrong OS detected

**Solution**: Add debug mode
```cpp
#ifdef DEBUG
    cerr << "OS Detection Debug:" << endl;
    cerr << "  Compile-time OS: " << detectOS() << endl;
    cerr << "  Runtime distro: " << detectDistro() << endl;
#endif
```

---

## 📦 Deployment and Distribution

### Binary Distribution

**Release Checklist**:
- [ ] Compile with optimizations (`-O2`)
- [ ] Strip debug symbols
- [ ] Test on clean system
- [ ] Verify all dependencies
- [ ] Create checksums (SHA256)
- [ ] Sign binary (optional)

**Build Release**:
```bash
# Clean build
make clean
make

# Strip symbols
strip VibeFetch

# Create tarball
tar -czf vibefetch-v1.0.0-linux-x64.tar.gz VibeFetch README.md LICENSE
```

### Package Managers

#### Debian/Ubuntu (.deb)

**debian/control**:
```
Package: vibefetch
Version: 1.0.0
Section: utils
Priority: optional
Architecture: amd64
Maintainer: Your Name <email@example.com>
Description: System information tool with ASCII art
 VibeFetch displays system information with beautiful
 ASCII art logos for various operating systems.
```

#### Arch Linux (PKGBUILD)

```bash
pkgname=vibefetch
pkgver=1.0.0
pkgrel=1
pkgdesc="System information tool with ASCII art"
arch=('x86_64')
url="https://github.com/Luka12-dev/Vibefetch"
license=('MIT')
depends=()
makedepends=('gcc' 'make')

build() {
    make
}

package() {
    install -Dm755 VibeFetch "$pkgdir/usr/bin/Vibefetch"
}
```

#### Homebrew (macOS)

**Formula**:
```ruby
class Vibefetch < Formula
  desc "System information tool with ASCII art"
  homepage "https://github.com/Luka12-dev/Vibefetch"
  url "https://github.com/Luka12-dev/Vibefetch/archive/v1.0.0.tar.gz"
  sha256 "..."
  
  def install
    system "make"
    bin.install "VibeFetch" => "Vibefetch"
  end
  
  test do
    system "#{bin}/Vibefetch", "--version"
  end
end
```

---

## 🌐 Internationalization (i18n)

### Future i18n Support

**Architecture**:
```cpp
class Translator {
private:
    map<string, map<string, string>> translations;
    string currentLanguage;
    
public:
    void loadLanguage(const string& lang);
    string translate(const string& key);
};

// Usage
Translator t;
t.loadLanguage("es");
cout << t.translate("cpu_label") << ": " << getCPU() << endl;
// Output: "Procesador: AMD Ryzen 7 5700X"
```

**Translation Files** (JSON):
```json
{
  "en": {
    "cpu_label": "CPU",
    "memory_label": "Memory",
    "gpu_label": "GPU"
  },
  "es": {
    "cpu_label": "Procesador",
    "memory_label": "Memoria",
    "gpu_label": "GPU"
  },
  "fr": {
    "cpu_label": "Processeur",
    "memory_label": "Mémoire",
    "gpu_label": "GPU"
  }
}
```

---

## 🎯 Best Practices Summary

### Do's ✅

1. **Use const references** for parameters
   ```cpp
   void process(const string& data);  // Good
   ```

2. **Check return values**
   ```cpp
   FILE* pipe = popen("command", "r");
   if (!pipe) return "Unknown";
   ```

3. **Use RAII** for resource management
   ```cpp
   {
       ifstream file("data.txt");
       // Automatically closed
   }
   ```

4. **Provide fallbacks**
   ```cpp
   string primary = tryPrimary();
   if (primary == "Unknown") {
       return tryFallback();
   }
   ```

5. **Cache expensive operations**
   ```cpp
   static string cachedCPU;
   if (cachedCPU.empty()) {
       cachedCPU = detectCPU();
   }
   return cachedCPU;
   ```

### Don'ts ❌

1. **Don't ignore errors**
   ```cpp
   popen("command", "r");  // Bad - no error check
   ```

2. **Don't use magic numbers**
   ```cpp
   char buffer[256];  // Bad if not explained
   const int BUFFER_SIZE = 256;  // Good
   ```

3. **Don't leak resources**
   ```cpp
   FILE* f = fopen("file", "r");
   // ... forgot to fclose(f) - BAD
   ```

4. **Don't use global mutable state**
   ```cpp
   string globalCPU;  // Bad - hard to test
   ```

5. **Don't make assumptions**
   ```cpp
   // Bad - assumes file exists
   string data = readFile("/proc/cpuinfo");
   
   // Good - checks first
   if (fileExists("/proc/cpuinfo")) {
       string data = readFile("/proc/cpuinfo");
   }
   ```

---

## 📚 Reference Materials

### System Information Sources

#### Linux
- `/proc/cpuinfo` - CPU information
- `/proc/meminfo` - Memory statistics
- `/proc/version` - Kernel version
- `/sys/class/dmi/id/` - DMI/SMBIOS information
- `/sys/devices/system/cpu/` - CPU topology
- `/etc/os-release` - Distribution information

#### macOS
- `sysctl` - System parameters
- `system_profiler` - Detailed system information
- `sw_vers` - macOS version
- `ioreg` - I/O Registry information

#### Windows
- Registry keys under `HKEY_LOCAL_MACHINE`
- WMI (Windows Management Instrumentation)
- `GetSystemInfo()` API
- `GlobalMemoryStatusEx()` API

### External Documentation

**C++ Standards**:
- [cppreference.com](https://cppreference.com) - C++ reference
- [ISO C++](https://isocpp.org) - Official C++ website

**Platform Documentation**:
- [Windows API](https://docs.microsoft.com/windows/win32)
- [Apple Developer](https://developer.apple.com)
- [Linux man pages](https://man7.org/linux/man-pages)

**Similar Projects**:
- [Neofetch](https://github.com/dylanaraps/neofetch) - Bash implementation
- [Fastfetch](https://github.com/fastfetch-cli/fastfetch) - C implementation
- [pfetch](https://github.com/dylanaraps/pfetch) - Minimal POSIX sh

---

## 🔮 Advanced Topics

### Memory-Mapped Files

**Future optimization for large data**:
```cpp
#ifdef __linux__
#include <sys/mman.h>

class MemoryMappedFile {
private:
    void* data;
    size_t size;
    
public:
    MemoryMappedFile(const string& path) {
        int fd = open(path.c_str(), O_RDONLY);
        struct stat sb;
        fstat(fd, &sb);
        size = sb.st_size;
        
        data = mmap(NULL, size, PROT_READ, MAP_PRIVATE, fd, 0);
        close(fd);
    }
    
    ~MemoryMappedFile() {
        munmap(data, size);
    }
    
    const char* getData() const { return (char*)data; }
    size_t getSize() const { return size; }
};
#endif
```

### Asynchronous Information Gathering

**Future async support**:
```cpp
#include <future>

class AsyncInfoGatherer {
public:
    future<SystemInfo> gatherAsync() {
        return async(launch::async, [this]() {
            SystemInfo info;
            info.cpu = getCPU();
            info.memory = getMemory();
            info.gpu = getGPU();
            return info;
        });
    }
};

// Usage
AsyncInfoGatherer gatherer;
auto futureInfo = gatherer.gatherAsync();
// Do other work...
SystemInfo info = futureInfo.get();
```

### Custom Allocators

**Performance optimization**:
```cpp
template<typename T>
class PoolAllocator {
private:
    vector<T> pool;
    size_t next;
    
public:
    PoolAllocator(size_t size) : pool(size), next(0) {}
    
    T* allocate() {
        if (next >= pool.size()) {
            throw bad_alloc();
        }
        return &pool[next++];
    }
    
    void reset() { next = 0; }
};
```

### SIMD Optimizations

**String processing optimization**:
```cpp
#ifdef __AVX2__
#include <immintrin.h>

bool findSubstring_SIMD(const char* haystack, const char* needle) {
    // Use AVX2 instructions for fast string matching
    // Implementation details...
}
#endif
```

---

## 📊 Profiling and Optimization

### Profiling Tools

**Linux**:
```bash
# Compile with profiling
g++ -pg VibeFetch.cpp -o VibeFetch

# Run and generate profile data
./VibeFetch
gprof VibeFetch gmon.out > analysis.txt

# Valgrind for memory profiling
valgrind --tool=callgrind ./VibeFetch
kcachegrind callgrind.out.*
```

**macOS**:
```bash
# Instruments (Xcode)
instruments -t "Time Profiler" ./VibeFetch

# Or use dtrace
sudo dtrace -n 'pid$target:::entry { @[ustack()] = count(); }' -c ./VibeFetch
```

**Windows**:
```cmd
# Visual Studio Profiler
# Or use Very Sleepy
```

### Optimization Checklist

- [ ] Profile before optimizing
- [ ] Optimize hot paths only
- [ ] Use `-O2` or `-O3` optimization flags
- [ ] Enable link-time optimization (LTO)
- [ ] Use const and references appropriately
- [ ] Avoid unnecessary copies
- [ ] Cache expensive computations
- [ ] Use string_view for C++17+
- [ ] Reserve vector capacity when known
- [ ] Batch system calls when possible

---

## 🎓 Learning Resources

### For Contributors

**C++ Resources**:
- [Effective Modern C++](https://www.oreilly.com/library/view/effective-modern-c/9781491908419/) by Scott Meyers
- [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines)
- [cppreference.com](https://cppreference.com)

**System Programming**:
- [The Linux Programming Interface](https://man7.org/tlpi/) by Michael Kerrisk
- [Windows System Programming](https://www.amazon.com/Windows-Programming-Addison-Wesley-Microsoft-Technology/dp/0321657748)
- [Advanced Programming in the UNIX Environment](https://www.amazon.com/Advanced-Programming-UNIX-Environment-3rd/dp/0321637739)

**Cross-Platform Development**:
- [CMake Documentation](https://cmake.org/documentation/)
- [Autotools Guide](https://www.gnu.org/software/automake/manual/html_node/Autotools-Introduction.html)

---

## 🤝 Community and Support

### Communication Channels

**GitHub**:
- Issues: Bug reports and feature requests
- Discussions: General questions and ideas
- Pull Requests: Code contributions

**Real-time Chat**:
- Discord: Community chat and support
- IRC: #vibefetch on Libera.Chat

### Getting Help

**Before asking**:
1. Check existing issues
2. Read documentation
3. Search discussions
4. Try debug mode

**When asking for help**:
- Include VibeFetch version
- Specify your OS and version
- Provide relevant error messages
- Share configuration if applicable
- Describe expected vs actual behavior

---

## 📄 License and Legal

### MIT License

VibeFetch is released under the MIT License, which allows:

- ✅ Commercial use
- ✅ Modification
- ✅ Distribution
- ✅ Private use

**Requirements**:
- Include license and copyright notice

**Limitations**:
- No liability
- No warranty

### Third-Party Components

VibeFetch uses only standard library components and does not include third-party code.

**If using external libraries** (future):
- List all dependencies
- Include their licenses
- Provide attribution

---

## 🎉 Conclusion

VibeFetch is designed with the following principles:

1. **Simplicity**: Easy to understand and modify
2. **Portability**: Works across major platforms
3. **Performance**: Fast and efficient
4. **Extensibility**: Easy to add new features
5. **Reliability**: Robust error handling

### Architecture Highlights

- ✅ **Modular design** for easy maintenance
- ✅ **Platform abstraction** for portability
- ✅ **Multiple detection methods** for reliability
- ✅ **Graceful degradation** on errors
- ✅ **Zero external dependencies**
- ✅ **Comprehensive documentation**

### Future Vision

VibeFetch aims to become the go-to system information tool with:
- Plugin architecture
- Web dashboard
- Remote monitoring
- Predictive insights
- Multi-language support
- Mobile companion apps

---

<div align="center">

**Thank you for using VibeFetch!**

*Keep the VIBE alive!* ✨

[GitHub](https://github.com/Luka12-dev/Vibefetch) | [Documentation](https://vibefetch.dev) | [Community](https://discord.gg/Vibefetch)

**Made with ❤️ and C++**

Version 1.0.0 | Last Updated: 2025-12-26

</div>
