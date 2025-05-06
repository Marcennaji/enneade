# 🧭 Enneade Roadmap

This roadmap describes the planned evolution of the Enneade project toward a maintainable, testable, and extensible architecture that adheres to SOLID principles.

---

## ✅ Phase 1 – Foundations

- [x] Migrate Enneade code to compile with Khiops v. 10.7
- [x] Create a Windows installer 
- [x] Validate core workflows via GUI (still ongoing)
- [x] Move files into domain-specific folders (`domain/`, `ui/`, `application/`, etc.)
- [x] Limit `#include` dependencies and make systematic use of forward declarations
- [x] Define minimal unit and integration tests
- [x] Set up GitHub Actions for:
  - Automatic compilation
  - Running tests
  - Tracking test failures
- [ ] Add code coverage tracking (`gcov + lcov`, `codecov`, or similar)

---

## 🛠️ Phase 2 – Code Refactoring & Design Improvements

### 🔁 Structure
- [ ] Introduce matching C++ namespaces
- [ ] Analyze design structure using **CppDepend**

### 🧱 Decoupling & Clean Architecture
- [ ] Minimize coupling between components:
  - Prefer composition over inheritance (where appropriate)
  - Introduce Khiops adapter classes in `infrastructure/khiops_wrappers`
- [ ] Replace inheritance from KW* classes with adapters (where possible)

### 🧪 Testing
- [ ] Create unit tests for core components
- [ ] Maintain non-regression test suite (end-to-end workflows)

---

## 🧹 Phase 3 – Static Analysis & Quality Gates

- [ ] Add static analysis tools (at least `clang-tidy`, `CppDepend`)
- [ ] Integrate static analysis into GitHub Actions
- [ ] Define quality gates:
  - Max class/function size
  - No cyclic dependencies
  - Code duplication thresholds
  - Minimum code coverage %

---

## 🚀 Phase 4 – Extension & Packaging

### 🔬 Python API
- [ ] Expose Enneade core as a Python module using the same strategy as Khiops (e.g., pybind11)

---

## 📚 Documentation

- [ ] Add Doxygen configuration and generate documentation
- [ ] Write high-level design documents for each domain module
- [ ] Maintain a `CHANGELOG.md` or GitHub releases notes

---

## 🧩 Notes

- Enneade is based on the Khiops library. The goal is to progressively isolate Khiops-specific code inside the `infrastructure/` layer.
- Every refactoring task must preserve observable behavior (verified through tests).
- All design changes are measured against maintainability, testability, and modularity.

---

> Last updated: April 2025