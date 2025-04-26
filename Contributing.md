# Contributing to Enneade

First of all, thank you for considering contributing to **Enneade**!  
We appreciate your time and effort to improve the project.

This document describes how you can help and the standards we follow.

---

## 📋 Before You Start

- Ensure you have read and understood the [README](README.md).
- Ensure your work aligns with the project goals: clean code, modular architecture, modern C++ best practices.
- Familiarize yourself with our code quality tools (CppDepend, SonarQube) and coding style.

---

## 🛠️ How to Contribute

1. **Fork** the repository and **clone** it locally.

2. **Create a new branch**:
   ```bash
   git checkout -b feature/YourFeatureName
   ```

3. **Make your changes**, keeping the following in mind:
   - Write clean, readable, and maintainable C++ code.
   - Respect SOLID principles and design guidelines.
   - Avoid introducing new code smells or quality regressions.
   - Add or update unit tests and integration tests if necessary.

4. **Build and Test**:
   - Ensure that the project builds successfully.
   - Run all tests and verify that they pass.
   - Check that CppDepend/SonarQube quality gates are satisfied.

5. **Commit your changes**:
   - Write clear and concise commit messages.
   - Use the imperative mood (e.g., "Add", "Fix", "Refactor").

6. **Push your branch**:
   ```bash
   git push origin feature/YourFeatureName
   ```

7. **Open a Pull Request** against the main branch:
   - Describe what you have done and why.
   - Reference related issues if applicable (Closes #123).

## 🧹 Code Style

- Prefer modern C++ standards (C++17 or later).
- Use smart pointers over raw pointers where applicable.
- Favor composition over inheritance when possible.
- Minimize dependencies between modules.
- Write small, single-responsibility functions and classes.

## ✅ Pull Request Review Checklist

Before submitting a Pull Request, please make sure:

- [ ] Code builds without errors or warnings.
- [ ] Tests pass successfully.
- [ ] No degradation of static analysis metrics (CppDepend, SonarQube).
- [ ] Code follows the project's style and design principles.
- [ ] Documentation is updated if necessary.

