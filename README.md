# 16×16 Multiplier Design using Verilog

## Array Multiplier vs Wallace Tree Multiplier with Pipelined Han–Carlson Adder

---

## 📌 Overview

This project presents the **design, simulation, synthesis, and timing analysis** of two different 16-bit multiplier architectures implemented in **Verilog HDL** using **Vivado**:

1. **16×16 Array Multiplier**
2. **16×16 Wallace Tree Multiplier** using

   * **7:3 and 3:2 compressors**
   * **Pipelined Han–Carlson parallel prefix adder** for the final stage

The project is developed as part of the **Computer Organization and Architecture (COA)** course under the guidance of **Prof. Rajat Sadhukhan**.

---

## 🎯 Objectives

* Implement a **functional 16×16 multiplier** in Verilog
* Optimize the Wallace Tree design for **high frequency (≈250 MHz)**
* Achieve **positive WNS** with a **datapath delay between 3–4 ns**
* Compare **Array vs Wallace Tree** architectures
* Understand the impact of **compressors, pipelining, and prefix adders**

---

## 🏗️ Design Architecture

### 1️⃣ Array Multiplier

* Hierarchical divide-and-conquer design
* 16×16 built using:

  * 8×8 multipliers
  * 4×4 multipliers
  * 2×2 multipliers
* Purely combinational
* Simple structure but **large critical path**

**Time Complexity**

* Overall: **O(n²)**
* Critical path: **O(n · log n)**

---

### 2️⃣ Wallace Tree Multiplier (Optimized Design)

* Partial products generated in parallel
* Reduction using:

  * **7:3 compressors**
  * **3:2 compressors**
* Multi-stage **pipelined architecture**
* Final addition using a **Han–Carlson Adder**

#### Why Han–Carlson Adder?

* Hybrid of **Kogge–Stone** and **Brent–Kung** adders
* Balanced trade-off between:

  * Speed
  * Wiring complexity
  * FPGA routability
* Suitable for **high-frequency pipelined datapaths**

---

## ⏱️ Pipelining Strategy

Pipelines are inserted at:

1. Partial product generation
2. After first 7:3 compressor stage
3. After second reduction stage
4. After 3:2 compressor stage
5. Inside the Han–Carlson adder

✔ This ensures that the **critical path is limited to a single pipeline stage**, not the entire datapath.

---

## 🔍 Critical Path Explanation

* In a **pipelined design**, the critical path is:

  **👉 The longest combinational delay between two pipeline registers**

* NOT the full input-to-output delay

* For this design, the critical path lies in:

  * The **prefix computation stage of the Han–Carlson adder**

**Measured datapath delay:**
**≈ 3.9 ns**, enabling ~250 MHz operation with **positive WNS**

---

## 📊 Synthesis Results (Vivado)

| Multiplier Type  | LUTs | FFs | DSPs | Max Frequency (MHz) | Critical Path (ns) |
| ---------------- | ---- | --- | ---- | ------------------- | ------------------ |
| Array Multiplier | 466  | 0   | 0    | 49.58               | 20.17              |
| Wallace Tree     | 572  | 701 | 0    | **256.21**          | **3.90**           |

✔ Wallace Tree achieves **~5× speedup**
✔ Moderate increase in hardware resources is justified by performance gain

---

## 🧪 Simulation & Verification

* Self-checking Verilog testbenches
* Tested with:

  * Corner cases (0, maximum values)
  * Random test vectors
* Wallace Tree shows expected **pipeline latency**
* Functional correctness verified across all tests

---

## 📁 Repository Structure

```
├── Array_Mult.v                 # 16×16 Array Multiplier
├── Array_tb.v                   # Testbench for Array Multiplier
├── wallace_multiplier.v         # Wallace Tree Multiplier
├── Wallace_tb.v                 # Testbench for Wallace Tree
├── Wallace_const.xdc            # Vivado timing constraints
├── 24114105_COA_Assignment_Report.docx  # Detailed project report
├── README.md                    # Project documentation
```

✔ The **detailed report** explaining design choices, theory, simulations, and synthesis results is included directly in this repository.

---

## ⚙️ Tools Used

* **Vivado** (Simulation, Synthesis, Implementation)
* **Verilog HDL**
* **XSim** for behavioral simulation

---

## 🧠 Key Learnings

* Compressor-based reduction significantly reduces Wallace Tree depth
* **7:3 compressors** improve reduction efficiency
* Proper **pipelining is essential** for high-frequency operation
* Prefix adder structure directly impacts timing and routing
* **Critical path ≠ total latency** in pipelined systems

---

## ✅ Conclusion

The **Wallace Tree Multiplier with a pipelined Han–Carlson adder** significantly outperforms the Array Multiplier, achieving:

* **~250 MHz clock frequency**
* **3–4 ns datapath delay**
* **Positive WNS**

This makes the Wallace Tree architecture suitable for **high-performance arithmetic units**, while the Array Multiplier remains useful for simpler, low-speed designs.

---

## 👨‍🎓 Author & Course Information

* **Author:** Vishal Kumar Shaw
* **Enrollment No:** 24114105
* **Course:** Computer Organization and Architecture (COA)
* **Instructor:** **Prof. Rajat Sadhukhan**

---

## 📚 References

* Morris Mano – *Computer System Architecture*
* Harris & Harris – *Digital Design and Computer Architecture*
* IEEE papers on Wallace Tree multipliers
* Vivado Design Suite Documentation
