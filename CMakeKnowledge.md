# CMake 知识点汇总（Step 0 ~ Step 9）

---

## Step 0：Hello World

### `cmake_minimum_required(VERSION <version>)`

```cmake
cmake_minimum_required(VERSION 3.23)
```

- 指定 CMake 最低版本要求，必须放在 `CMakeLists.txt` 的第一行
- 如果 CMake 版本低于指定值，会报错终止

### `project(<name>)`

```cmake
project(Tutorial)
```

- 定义项目名称
- 隐式设置变量 `PROJECT_NAME`

### `add_executable(<name>)`

```cmake
add_executable(hello)
```

- 创建一个可执行文件目标
- 可以在创建时不指定源文件，后续通过 `target_sources` 添加

### `target_sources`

```cmake
target_sources(hello
  PRIVATE
    HelloWorld.cxx
)
```

- 为目标添加源文件
- `PRIVATE`：源文件仅用于构建该目标本身

---

## Step 1：多目标与子目录

### `add_library(<name>)`

```cmake
add_library(MathFunctions)
```

- 创建一个库目标（默认为静态库）
- 可以不指定源文件，后续通过 `target_sources` 添加

### `target_sources` + `FILE_SET`

```cmake
target_sources(MathFunctions
    PRIVATE
        MathFunctions/MathFunctions.cxx

    PUBLIC
        FILE_SET HEADERS
        TYPE HEADERS
        BASE_DIRS
            MathFunctions
        FILES
            MathFunctions/MathFunctions.h
)
```

- `PRIVATE`：源文件仅供目标自身编译使用
- `PUBLIC`：头文件对依赖该目标的使用者可见
- `FILE_SET HEADERS`：声明头文件集合
- `TYPE HEADERS`：指定文件集类型为头文件
- `BASE_DIRS`：头文件的根目录，`#include` 时基于此目录
- `FILES`：具体的头文件列表

### `target_link_libraries`

```cmake
target_link_libraries(Tutorial
    PRIVATE
        MathFunctions
)
```

- 将库链接到目标
- `PRIVATE`：库仅用于链接该目标，不传递给依赖者

### `add_subdirectory`

```cmake
add_subdirectory(Tutorial)
add_subdirectory(MathFunctions)
```

- 添加子目录，子目录中必须有自己的 `CMakeLists.txt`
- 子目录的 `CMakeLists.txt` 会被处理

---

## Step 2：宏、函数与列表操作

### `macro` / `endmacro`

```cmake
macro(MacroAppend ListVar Value)
  set(${ListVar} "${${ListVar}};${Value}")
endmacro()
```

- 定义一个宏
- **宏在调用者的作用域中执行**（类似 C 的 `#define`，文本替换）
- 参数通过 `${ListVar}` 直接访问

### `function` / `endfunction`

```cmake
function(FuncAppend ListVar Value)
  MacroAppend(${ListVar} ${Value})
  set(${ListVar} "${${ListVar}}" PARENT_SCOPE)
endfunction()
```

- 定义一个函数
- **函数有独立的作用域**，变量不会自动传回调用者
- 需要通过 `PARENT_SCOPE` 将变量传回父作用域

### `set`

```cmake
set(MyVar "value")
set(${ListVar} "${${ListVar}};${Value}")
set(${ListVar} "${${ListVar}}" PARENT_SCOPE)
```

- 设置变量值
- 使用 `;` 分隔符创建列表
- `PARENT_SCOPE`：将变量设置在父作用域

### `PARENT_SCOPE`

- 用于 `set()` 或函数内部，将变量值传递到调用者的作用域
- 函数内部的修改不会自动影响外部变量

### `ARGN`

- 函数/宏中的隐式变量，包含所有未命名的额外参数
- 配合 `foreach` 遍历不定数量的参数

### `foreach` / `endforeach`

```cmake
foreach(item IN LISTS ARGN)
  ...
endforeach()
```

- 遍历列表中的每个元素
- `IN LISTS`：指定遍历一个列表变量

### `if` / `elseif` / `else` / `endif`

```cmake
if(item MATCH Foo)
  ...
endif()

if(STREQUAL Original)
  ...
elseif(NOT EndList STREQUAL Expected)
  ...
else()
  ...
endif()
```

- 条件判断
- `MATCH`：正则匹配
- `STREQUAL`：字符串相等比较
- `NOT`：逻辑取反
- `AND`：逻辑与
- `DEFINED`：检查变量是否已定义

### `list(APPEND ...)`

```cmake
list(APPEND ${OutVar} ${item})
```

- 向列表追加元素
- `APPEND`：在列表末尾添加元素

### `list(FILTER ... EXCLUDE REGEX ...)`

```cmake
list(FILTER ARGN EXCLUDE REGEX Foo)
```

- 过滤列表
- `EXCLUDE REGEX`：排除匹配正则表达式的元素

### `IN_LIST`

```cmake
if(NOT var IN_LIST OutList)
```

- 判断某元素是否在列表中

### `message`

```cmake
message("text")
message(WARNING "warning text")
```

- 输出消息
- `WARNING`：输出警告信息

### `return()`

```cmake
if(SKIP_TESTS)
  return()
endif()
```

- 提前结束当前 `CMakeLists.txt` 文件的处理

### `include`

```cmake
include(Exercise1.cmake)
include(Exercise2.cmake)
```

- 包含并执行另一个 `.cmake` 文件
- 与 `add_subdirectory` 不同，不会创建新的作用域

### `cmake_minimum_required`

```cmake
cmake_minimum_required(VERSION 3.23)
```

- 在 `.cmake` 文件中同样需要声明最低版本

---

## Step 3：选项与 CMake Presets

### `option`

```cmake
option(TUTORIAL_BUILD_UTILITIES "Build the Tutorial executable" ON)
```

- 定义一个布尔类型的缓存变量（用户可在 GUI 或命令行中修改）
- 第二个参数是描述字符串
- 第三个参数是默认值（`ON` 或 `OFF`）

### `if` + 选项变量

```cmake
if(TUTORIAL_BUILD_UTILITIES)
  add_subdirectory(Tutorial)
endif()
```

- 根据选项值条件性地构建目标

### `CMakePresets.json`

```json
{
  "version": 4,
  "configurePresets": [
    {
      "name": "tutorial",
      "displayName": "Tutorial Preset",
      "description": "Preset to use with the tutorial",
      "binaryDir": "${sourceDir}/build",
      "cacheVariables": {
        "CMAKE_CXX_STANDARD": "20"
      }
    }
  ]
}
```

- `version`：Presets 格式版本
- `configurePresets`：配置预设数组
- `name`：预设名称，用于 `cmake --preset=<name>`
- `displayName`：显示名称
- `description`：描述信息
- `binaryDir`：构建输出目录，`${sourceDir}` 是 CMake 内置变量
- `cacheVariables`：预设的缓存变量，等同于 `-D` 命令行参数

### `CMAKE_CXX_STANDARD`

```json
"CMAKE_CXX_STANDARD": "20"
```

- CMake 内置变量，设置 C++ 标准版本
- 也可以在 CMakeLists.txt 中通过 `set(CMAKE_CXX_STANDARD 20)` 设置

---

## Step 4：编译特性、编译定义与编译选项

### `option`（默认 OFF）

```cmake
option(TUTORIAL_USE_STD_SQRT "Use std::sqrt" OFF)
```

- 默认值为 `OFF`，用户需显式启用

### `target_compile_features`

```cmake
target_compile_features(MathFunctions PRIVATE cxx_std_20)
```

- 为目标指定需要的编译器特性
- `cxx_std_20`：要求 C++20 支持
- CMake 会自动添加对应的编译器标志（如 `-std=c++20`）
- `PRIVATE`：仅影响该目标自身

### `target_compile_definitions`

```cmake
target_compile_definitions(MathFunctions PRIVATE TUTORIAL_USE_STD_SQRT)
```

- 为目标添加预处理宏定义（等同于编译器的 `-D` 标志）
- `PRIVATE`：仅影响该目标自身
- 在 C++ 代码中通过 `#ifdef` / `#ifndef` 使用

### `target_compile_options`

```cmake
# MSVC
target_compile_options(Tutorial PRIVATE /W3)

# GCC / Clang
target_compile_options(Tutorial PRIVATE -Wall)
```

- 为目标添加编译器选项
- 不同编译器使用不同的标志

### `CMAKE_CXX_COMPILER_ID`

```cmake
if(
  (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC") OR
  (CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
)
```

- CMake 内置变量，标识当前编译器
- 常见值：`MSVC`、`GNU`、`Clang`、`AppleClang`

### `CMAKE_CXX_COMPILER_FRONTEND_VARIANT`

- CMake 内置变量，标识编译器前端变体
- 用于区分 MSVC 和 Clang-CL（两者 `CMAKE_CXX_COMPILER_ID` 不同但前端相同）

### `add_library(... INTERFACE)`

```cmake
add_library(VendorLib INTERFACE)
```

- 创建一个 **INTERFACE 库**（无源文件，不编译）
- 仅用于传递头文件、编译定义、链接目录等属性
- 适合封装第三方库（预编译库 + 头文件）

### `target_compile_definitions(... INTERFACE)`

```cmake
target_compile_definitions(VendorLib INTERFACE TUTORIAL_USE_VENDORLIB)
```

- `INTERFACE`：宏定义会传递给所有链接该库的目标

### `target_include_directories`

```cmake
target_include_directories(VendorLib
    INTERFACE
        include
)
```

- 为目标添加头文件搜索路径
- `INTERFACE`：路径会传递给链接该库的目标

### `target_link_directories`

```cmake
target_link_directories(VendorLib
    INTERFACE
        lib
)
```

- 为目标添加库文件搜索路径
- `INTERFACE`：路径会传递给链接该库的目标

### `target_link_libraries(... INTERFACE)`

```cmake
target_link_libraries(VendorLib
    INTERFACE
        Vendor
)
```

- `INTERFACE`：库会传递给链接 VendorLib 的目标

### C++ 预处理宏（配合 CMake）

```cpp
#ifdef TUTORIAL_USE_STD_SQRT
  return std::sqrt(x);
#else
  return mysqrt(x);
#endif
```

- 通过 `target_compile_definitions` 在 CMake 中定义宏
- 在 C++ 代码中通过 `#ifdef` / `#else` / `#endif` 条件编译

---

## Step 5：库类型、链接可见性与多层子目录

### `add_library(... OBJECT)`

```cmake
add_library(OpAdd OBJECT)

target_sources(OpAdd
  PRIVATE
    OpAdd.cxx

  INTERFACE
    FILE_SET HEADERS
    FILES
      OpAdd.h
)
```

- 创建一个 **OBJECT 库**（对象库）
- 源文件会被编译为 `.obj` / `.o` 文件，但不打包为 `.a` / `.lib`
- 对象文件会自动合并到链接该库的目标中
- 比静态库更高效，避免了打包/解包步骤
- 适合拆分编译单元但不需要独立归档的场景

### `add_library(... INTERFACE)` + `FILE_SET HEADERS`（无 FILES）

```cmake
add_library(MathLogger INTERFACE)

target_sources(MathLogger
  INTERFACE
    FILE_SET HEADERS
)
```

- 创建 INTERFACE 库时，`FILE_SET HEADERS` 不指定 `FILES`，默认使用当前源目录下的所有头文件
- 适合头文件-only 的库（header-only library）

### `target_link_libraries` 混合 PRIVATE / PUBLIC

```cmake
target_link_libraries(MathFunctions
  PRIVATE
    MathLogger

  PUBLIC
    OpAdd
    OpMul
    OpSub
)
```

- 一次调用中可以同时指定 `PRIVATE` 和 `PUBLIC` 依赖
- `PRIVATE MathLogger`：MathLogger 仅在 MathFunctions 的实现中使用，不暴露给消费者
- `PUBLIC OpAdd/OpMul/OpSub`：这些库的头文件在 MathFunctions.h 中被引用，必须对消费者可见

### `BUILD_SHARED_LIBS`

```json
"cacheVariables": {
  "BUILD_SHARED_LIBS": "ON"
}
```

- CMake 内置变量，控制 `add_library()` 的默认库类型
- `ON`：默认构建共享库（`.dll` / `.so`）
- `OFF`（默认）：默认构建静态库（`.lib` / `.a`）
- 仅影响未显式指定类型的 `add_library()` 调用

### 多层子目录结构

```cmake
# MathFunctions/CMakeLists.txt
add_subdirectory(MathLogger)
add_subdirectory(MathExtensions)

# MathFunctions/MathExtensions/CMakeLists.txt
add_subdirectory(OpAdd)
add_subdirectory(OpMul)
add_subdirectory(OpSub)
```

- `add_subdirectory` 可以嵌套使用，形成树状项目结构
- 每个子目录拥有独立的 `CMakeLists.txt`
- 子目录中定义的目标在整个项目中可见（全局目标名）

---

## Step 6：IPO、头文件检测与源码编译检测

### `option` + IPO

```cmake
option(TUTORIAL_ENABLE_IPO "Check for and use IPO support" ON)
```

- 定义选项控制是否启用 IPO（Interprocedural Optimization，过程间优化）
- IPO 可以跨编译单元进行优化（如内联、死代码消除等）

### `include(CheckIPOSupported)` + `check_ipo_supported`

```cmake
include(CheckIPOSupported)
check_ipo_supported(RESULT result OUTPUT output)
if(result)
  message("IPO is supported, enabling IPO")
  set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)
else()
  message(WARNING "IPO is not supported: ${output}")
endif()
```

- `include(CheckIPOSupported)`：加载 IPO 支持检测模块
- `check_ipo_supported(RESULT ... OUTPUT ...)`：检测当前编译器是否支持 IPO
  - `RESULT`：返回布尔结果变量
  - `OUTPUT`：返回详细信息变量
- `CMAKE_INTERPROCEDURAL_OPTIMIZATION`：全局启用 IPO 的 CMake 变量

### `include(CheckIncludeFiles)` + `check_include_files`

```cmake
include(CheckIncludeFiles)
check_include_files(emmintrin.h HAS_EMMINTRIN LANGUAGE CXX)

if(HAS_EMMINTRIN)
  target_compile_definitions(MathFunctions PRIVATE TUTORIAL_USE_SSE2)
endif()
```

- `include(CheckIncludeFiles)`：加载头文件检测模块
- `check_include_files(<header> <result_var> LANGUAGE <lang>)`
  - 检测指定头文件是否存在
  - `LANGUAGE CXX`：使用 C++ 编译器检测
  - 结果存入 `HAS_EMMINTRIN` 变量
- 配合 `target_compile_definitions` 条件性地定义宏

### `include(CheckSourceCompiles)` + `check_source_compiles`

```cmake
include(CheckSourceCompiles)
check_source_compiles(CXX
  [=[
    typedef double v2df __attribute__((vector_size(16)));
    int main() {
      __builtin_ia32_sqrtsd(v2df{});
    }
  ]=]
  HAS_GNU_BUILTIN
)

if(HAS_GNU_BUILTIN)
  target_compile_definitions(MathFunctions PRIVATE TUTORIAL_USE_GNU_BUILTIN)
endif()
```

- `include(CheckSourceCompiles)`：加载源码编译检测模块
- `check_source_compiles(<lang> <code> <result_var>)`
  - 尝试编译一段代码，检测是否成功
  - `CXX`：使用 C++ 编译器
  - 代码用 `[=[...]=]` 括号语法包裹（支持多行，无需转义）
  - 结果存入 `HAS_GNU_BUILTIN` 变量

### `[=[...]=]` 括号语法

```cmake
[=[
  这是多行字符串
  不需要转义特殊字符
]=]
```

- CMake 的括号语法用于多行字符串
- `=` 的数量可以增加以避免与内容中的 `]` 冲突
- 适合嵌入源代码片段

### C++ 中配合 CMake 宏的条件包含

```cpp
#ifdef TUTORIAL_USE_SSE2
#  include <emmintrin.h>
#endif
```

- 通过 `target_compile_definitions` 定义的宏控制头文件的条件包含
- 仅在检测到 SSE2 支持时才引入 `<emmintrin.h>`

---

## Step 7：自定义命令、自定义目标与代码生成

### `add_executable`（代码生成工具）

```cmake
add_executable(MakeTable)

target_sources(MakeTable
  PRIVATE
    MakeTable.cxx
)
```

- 创建一个构建时运行的可执行工具（build-time tool）
- 该工具在构建过程中被编译并运行，用于生成源代码或头文件
- 区分于最终产品（Tutorial），它是构建系统的辅助程序

### `add_custom_command`（OUTPUT 形式）

```cmake
add_custom_command(
  OUTPUT SqrtTable.h
  COMMAND MakeTable SqrtTable.h
  DEPENDS MakeTable
  VERBATIM
)
```

- 定义一个自定义命令，用于生成文件
- `OUTPUT`：指定生成的文件（构建系统会检查该文件是否存在/是否需要重新生成）
- `COMMAND`：要执行的命令（这里的 `MakeTable` 是构建目标，CMake 会自动使用其输出路径）
- `DEPENDS`：命令的依赖，当 `MakeTable` 可执行文件变化时会重新运行
- `VERBATIM`：确保参数被正确转义处理（推荐始终使用）
- 生成的文件路径默认在 `CMAKE_CURRENT_BINARY_DIR` 中

### `add_custom_target`

```cmake
add_custom_target(RunMakeTable DEPENDS SqrtTable.h)
```

- 创建一个自定义目标，不生成实际的库或可执行文件
- `DEPENDS SqrtTable.h`：依赖于 `add_custom_command` 的 OUTPUT
- 每次构建时都会触发（因为自定义目标总是被认为过时）
- 确保 `add_custom_command` 的 OUTPUT 文件始终被检查和重新生成

### `add_dependencies`

```cmake
add_dependencies(SqrtTable RunMakeTable)
```

- 在两个目标之间添加构建顺序依赖
- 确保 `RunMakeTable`（自定义目标）在 `SqrtTable`（INTERFACE 库）之前构建
- **不传递链接关系**，仅控制构建顺序
- 用于解决生成头文件的时序问题：先生成头文件，再编译依赖它的目标

### `CMAKE_CURRENT_BINARY_DIR`

```cmake
target_sources(SqrtTable
  INTERFACE
    FILE_SET HEADERS
    BASE_DIRS
      ${CMAKE_CURRENT_BINARY_DIR}
    FILES
      ${CMAKE_CURRENT_BINARY_DIR}/SqrtTable.h
)
```

- CMake 内置变量，表示当前 `CMakeLists.txt` 对应的构建目录
- `add_custom_command` 生成的文件默认在此目录中
- `FILE_SET HEADERS` 需要将 `BASE_DIRS` 设为 `${CMAKE_CURRENT_BINARY_DIR}`，以便 `#include <SqrtTable.h>` 能正确找到生成的头文件

### 代码生成模式总结

```cmake
# 1. 创建生成工具
add_executable(MakeTable)
target_sources(MakeTable PRIVATE MakeTable.cxx)

# 2. 定义生成命令
add_custom_command(
  OUTPUT SqrtTable.h
  COMMAND MakeTable SqrtTable.h
  DEPENDS MakeTable
  VERBATIM
)

# 3. 创建自定义目标（确保命令被触发）
add_custom_target(RunMakeTable DEPENDS SqrtTable.h)

# 4. 创建 INTERFACE 库来承载生成的头文件
add_library(SqrtTable INTERFACE)
target_sources(SqrtTable
  INTERFACE
    FILE_SET HEADERS
    BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR}
    FILES ${CMAKE_CURRENT_BINARY_DIR}/SqrtTable.h
)

# 5. 添加构建顺序依赖
add_dependencies(SqrtTable RunMakeTable)
```

- 完整的代码生成流程：**工具 → 命令 → 目标 → 库 → 依赖**
- 下游目标通过 `target_link_libraries(... SqrtTable)` 即可使用生成的头文件

---

## Step 8：测试

### `option(BUILD_TESTING ...)`

```cmake
option(BUILD_TESTING "Enable testing and build tests" ON)
```

- CMake 标准变量，控制是否启用测试
- 默认 `ON`，可通过 `-DBUILD_TESTING=OFF` 关闭

### `enable_testing()`

```cmake
enable_testing()
```

- 启用 CTest 测试支持
- 必须在 `add_test()` 之前调用
- 通常放在项目根目录的 `CMakeLists.txt` 中

### `add_test`

```cmake
add_test(
  NAME add
  COMMAND TestMathFunctions add
)
```

- 注册一个测试用例
- `NAME`：测试名称（在 `ctest` 中显示）
- `COMMAND`：要执行的命令（可执行文件 + 参数）
- 测试通过返回码判断成功/失败（0 = 通过）

### 用函数封装重复测试注册

```cmake
function(MathFunctionTest op)
  add_test(
    NAME ${op}
    COMMAND TestMathFunctions ${op}
  )
endfunction()

MathFunctionTest(add)
MathFunctionTest(mul)
MathFunctionTest(sqrt)
MathFunctionTest(sub)
```

- 当多个测试结构相似时，用 `function` 封装可以减少重复代码
- 每次调用 `MathFunctionTest(op)` 就会注册一个以 `op` 为名的测试

### 测试目标的构建模式

```cmake
# 1. 创建测试可执行文件
add_executable(TestMathFunctions)

# 2. 添加测试源文件
target_sources(TestMathFunctions
  PRIVATE
    TestMathFunctions.cxx
)

# 3. 链接被测库
target_link_libraries(TestMathFunctions
  PRIVATE
    MathFunctions
)
```

- 测试本身也是一个可执行目标
- 需要链接被测试的库
- 通过 `add_subdirectory(Tests)` 引入测试子目录

### 条件构建测试

```cmake
if(BUILD_TESTING)
  enable_testing()
  add_subdirectory(Tests)
endif()
```

- 用 `option` + `if` 包裹测试目录，允许用户选择是否构建测试
- 禁用测试可加速构建（尤其在 CI 中只做构建检查时）

---

## Step 9：安装与打包

### `project(... VERSION ...)`

```cmake
project(Tutorial
  VERSION 1.0.0
)
```

- 为项目指定版本号
- 自动设置变量：`PROJECT_VERSION`、`PROJECT_VERSION_MAJOR`、`PROJECT_VERSION_MINOR`、`PROJECT_VERSION_PATCH`
- 供后续 `write_basic_package_version_file` 使用

### `include(GNUInstallDirs)`

```cmake
include(GNUInstallDirs)
```

- 加载 GNU 标准安装目录变量模块
- 提供跨平台的安装路径变量：
  - `CMAKE_INSTALL_BINDIR`：可执行文件目录（`bin`）
  - `CMAKE_INSTALL_LIBDIR`：库文件目录（`lib` 或 `lib64`）
  - `CMAKE_INSTALL_INCLUDEDIR`：头文件目录（`include`）
- 推荐在所有 `install()` 中使用这些变量而非硬编码路径

### `install(TARGETS ... EXPORT ...)`

```cmake
install(
  TARGETS Tutorial
  EXPORT TutorialTargets
)
```

- 安装目标到系统目录
- `EXPORT`：将目标添加到一个导出集（export set），供其他项目通过 `find_package` 使用

### `install(TARGETS ... EXPORT ... FILE_SET HEADERS)`

```cmake
install(
  TARGETS MathFunctions OpAdd OpMul OpSub MathLogger SqrtTable
  EXPORT TutorialTargets
  FILE_SET HEADERS
)
```

- 安装目标时同时安装其 `FILE_SET HEADERS` 中声明的头文件
- 头文件会按照 `BASE_DIRS` 的结构安装到 `CMAKE_INSTALL_INCLUDEDIR`

### `install(EXPORT ... DESTINATION ... NAMESPACE ...)`

```cmake
install(
  EXPORT TutorialTargets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Tutorial
  NAMESPACE Tutorial::
)
```

- 安装导出集文件（`TutorialTargets.cmake`）
- `DESTINATION`：导出文件的安装路径
- `NAMESPACE`：为导出的目标添加命名空间前缀
  - 下游使用时需写 `Tutorial::MathFunctions` 而非 `MathFunctions`
  - 避免目标名冲突

### `include(CMakePackageConfigHelpers)` + `write_basic_package_version_file`

```cmake
include(CMakePackageConfigHelpers)

write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/TutorialConfigVersion.cmake
  COMPATIBILITY ExactVersion
)
```

- `include(CMakePackageConfigHelpers)`：加载包配置辅助模块
- `write_basic_package_version_file`：生成版本兼容性检查文件
  - `COMPATIBILITY ExactVersion`：要求 `find_package(Tutorial 1.0.0)` 必须精确匹配版本
  - 其他选项：`AnyNewerVersion`、`SameMajorVersion`、`SameMinorVersion`

### `install(FILES ... DESTINATION ...)`

```cmake
install(
  FILES
    cmake/TutorialConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/TutorialConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Tutorial
)
```

- 安装配置文件到指定目录
- `TutorialConfig.cmake`：包配置文件，定义 `find_package` 所需的导入逻辑
- `TutorialConfigVersion.cmake`：版本检查文件，由 `write_basic_package_version_file` 生成
- 两者必须安装到同一目录

### `TutorialConfig.cmake` 配置文件

```cmake
# cmake/TutorialConfig.cmake
include(${CMAKE_CURRENT_LIST_DIR}/TutorialTargets.cmake)
```

- 包配置文件，`find_package(Tutorial)` 时会自动加载
- `CMAKE_CURRENT_LIST_DIR`：当前 `.cmake` 文件所在目录
- 主要职责是引入 `TutorialTargets.cmake`（由 `install(EXPORT)` 生成）
- 下游通过 `find_package(Tutorial)` + `target_link_libraries(... Tutorial::MathFunctions)` 使用

### 完整的安装与打包流程

```cmake
# 1. 设置项目版本
project(Tutorial VERSION 1.0.0)

# 2. 加载标准安装目录
include(GNUInstallDirs)

# 3. 安装目标并导出
install(
  TARGETS MathFunctions OpAdd OpMul OpSub MathLogger SqrtTable
  EXPORT TutorialTargets
  FILE_SET HEADERS
)

# 4. 安装导出集（带命名空间）
install(
  EXPORT TutorialTargets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Tutorial
  NAMESPACE Tutorial::
)

# 5. 生成版本文件
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/TutorialConfigVersion.cmake
  COMPATIBILITY ExactVersion
)

# 6. 安装配置文件和版本文件
install(
  FILES
    cmake/TutorialConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/TutorialConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Tutorial
)
```

- 安装后，下游项目可通过 `find_package(Tutorial REQUIRED)` 使用
- 所有目标通过 `Tutorial::` 命名空间访问

---

## 速查表

| 命令 | Step | 用途 |
|------|------|------|
| `cmake_minimum_required` | 0-9 | 设置最低 CMake 版本 |
| `project` | 0, 1, 3-9 | 定义项目 |
| `project(... VERSION ...)` | 9 | 为项目指定版本号 |
| `add_executable` | 0, 1, 3-9 | 创建可执行目标 |
| `add_library` (默认/STATIC) | 1, 3-9 | 创建静态库目标 |
| `add_library` (OBJECT) | 5 | 创建对象库（编译但不打包） |
| `add_library` (INTERFACE) | 4-9 | 创建接口库（仅传递属性） |
| `target_sources` | 0, 1, 3-9 | 添加源文件 |
| `FILE_SET HEADERS` | 1, 3-9 | 声明头文件集合 |
| `target_link_libraries` | 1, 3-9 | 链接库 |
| `add_subdirectory` | 1, 3-9 | 添加子目录 |
| `macro` / `endmacro` | 2 | 定义宏（调用者作用域） |
| `function` / `endfunction` | 2, 8 | 定义函数（独立作用域） |
| `set` | 2 | 设置变量 |
| `PARENT_SCOPE` | 2 | 父作用域传递变量 |
| `ARGN` | 2 | 函数的额外参数 |
| `foreach` | 2 | 遍历列表 |
| `list(APPEND)` | 2 | 追加列表元素 |
| `list(FILTER)` | 2 | 过滤列表 |
| `IN_LIST` | 2 | 列表成员判断 |
| `include` | 2 | 包含 .cmake 文件 |
| `return` | 2 | 提前结束文件处理 |
| `message` | 2 | 输出消息 |
| `option` | 3-9 | 定义布尔选项 |
| `CMakePresets.json` | 3-9 | 配置预设 |
| `CMAKE_CXX_STANDARD` | 3 | 设置 C++ 标准版本 |
| `target_compile_features` | 4-9 | 指定编译器特性 |
| `target_compile_definitions` | 4-9 | 添加预处理宏定义 |
| `target_compile_options` | 4-9 | 添加编译器选项 |
| `CMAKE_CXX_COMPILER_ID` | 4-9 | 编译器标识 |
| `target_include_directories` | 4 | 添加头文件搜索路径 |
| `target_link_directories` | 4 | 添加库文件搜索路径 |
| `BUILD_SHARED_LIBS` | 5 | 控制默认库类型（静态/共享） |
| `include(CheckIPOSupported)` | 6-9 | 检测 IPO 支持 |
| `check_ipo_supported` | 6-9 | 检测编译器 IPO 支持 |
| `CMAKE_INTERPROCEDURAL_OPTIMIZATION` | 6-9 | 全局启用 IPO |
| `include(CheckIncludeFiles)` | 6-9 | 头文件存在性检测 |
| `check_include_files` | 6-9 | 检测指定头文件是否存在 |
| `include(CheckSourceCompiles)` | 6-9 | 源码编译检测 |
| `check_source_compiles` | 6-9 | 尝试编译代码检测特性 |
| `[=[...]=]` 括号语法 | 6-9 | 多行字符串（无需转义） |
| `add_custom_command` | 7-9 | 自定义命令（生成文件） |
| `add_custom_target` | 7-9 | 自定义目标（触发生成命令） |
| `add_dependencies` | 7-9 | 添加目标间构建顺序依赖 |
| `CMAKE_CURRENT_BINARY_DIR` | 7-9 | 当前构建目录 |
| `VERBATIM` | 7-9 | 确保参数正确转义 |
| `enable_testing` | 8, 9 | 启用 CTest 测试支持 |
| `add_test` | 8, 9 | 注册测试用例 |
| `BUILD_TESTING` | 8, 9 | 控制是否构建测试 |
| `include(GNUInstallDirs)` | 9 | 加载标准安装目录变量 |
| `CMAKE_INSTALL_LIBDIR` | 9 | 库文件安装目录 |
| `install(TARGETS ... EXPORT ...)` | 9 | 安装目标并导出 |
| `install(EXPORT ... NAMESPACE ...)` | 9 | 安装导出集（带命名空间） |
| `install(FILES ... DESTINATION ...)` | 9 | 安装配置文件 |
| `include(CMakePackageConfigHelpers)` | 9 | 包配置辅助模块 |
| `write_basic_package_version_file` | 9 | 生成版本兼容性检查文件 |
| `TutorialConfig.cmake` | 9 | 包配置文件（find_package 入口） |
