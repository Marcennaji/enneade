# Enneade

**Enneade** is a fork of [Khiops Enneade](https://github.com/KhiopsML/enneade), a clustering tool originally developed by Orange Labs as part of the Khiops suite.

The original *Khiops Enneade* is no longer maintained and was based on an outdated version of the Khiops library (v10.1).

**Enneade** includes a modified version of the KMeans algorithm as well as a KNN algorithm. It is highly tunable, delivers performant metrics, and offers unique features that set it apart. For a comprehensive guide to Enneade's features and usage, please refer to the [documentation](doc).

---

## 🚀 Goals of the Fork

The fork's main goals are:

- **Keeping up to date** with the latest Khiops releases to benefit from new features, performance improvements, and bug fixes.
- **Progressively improve the design and code quality**, measured through [CppDepend](https://www.cppdepend.com/) and [SonarQube](https://www.sonarsource.com/products/sonarqube/).
- **Implement a complete unit testing strategy**

---


## 🚧 Pre-Release Status 🚧

> **Warning:**  
> This version of Enneade is currently a **pre-release**, based on [Khiops library version 10.7.0-b.0](https://github.com/KhiopsML/khiops/releases/tag/10.7.0-b.0) . While functional, it has not yet been fully tested, and some features may be unstable or incomplete. Please use it with caution and report any issues you encounter.

---

## 🚀 Installation

A Windows installer is available in the [`packaging/windows/nsis`](packaging/windows/nsis) directory.

---

## 🛠️ Build Instructions

You need to have [CMake](https://cmake.org/) installed.

From the project root directory, run the following commands:

```bash
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
cmake --build build --target enneade
```
---
## 🤝 Roadmap

See [`ROADMAP.md`](ROADMAP.md) file.
> ⏳ Note: Enneade is maintained as a personal open-source project by a freelance developer.  
> Development progresses during personal time, outside of client work.  
> While the roadmap reflects clear goals, **no fixed delivery timelines are guaranteed**.


---
## 🤝 Contributing

See [`Contributing.md`](Contributing.md) file.

---

## 📜 License

This project is distributed under the **BSD-3-Clause License**.

You can find the full license text in the [LICENSE](LICENSE) file at the root of the repository.

