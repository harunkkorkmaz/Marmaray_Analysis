# 🚄 Marmaray: Physics-Based Operational Simulator

![MATLAB](https://img.shields.io/badge/Made_with-MATLAB-orange?style=for-the-badge&logo=mathworks)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

> A full-scale engineering simulation of Istanbul's Marmaray commuter line (Halkalı - Gebze), featuring kinematic analysis, thermal modeling, and a cinematic 3D visualization engine.

---

## 📖 Overview

This project is a **numerical modeling and simulation** study developed in MATLAB. It creates a "Digital Twin" of the 76-km Marmaray line, simulating the movement of a Hyundai Rotem E32000 train set across all 43 stations. 

Unlike simple animations, this project is driven by a custom **physics engine** that calculates forces, energy consumption, and thermal stress in real-time.

## 🚀 Key Features

### 1. Advanced Physics Engine
* **Stop-and-Go Logic:** Autonomous driving algorithm for 43 stations, calculating braking distances and acceleration profiles dynamically.
* **Variable Mass:** Simulates passenger load changes (Rush Hour scenarios) at key transfer hubs like Yenikapı and Söğütlüçeşme.
* **Forces:** Calculates Traction Force, Aerodynamic Drag, Rolling Resistance, and Gradient Resistance (Gravity).

### 2. 3D Visualization & Mapping
* **XYZ Coordinate System:** Maps the track topology including the deep underwater tunnel (Sirkeci-Üsküdar) submerged 60m below sea level.
* **Cinematic Mode:** Features a "Slow Motion" 3D follow-camera that zooms in during station stops and pans out during cruising.
* **Real-Time Dashboard:** Displays speed (km/h), power (kW), and thermal data instantly.

### 3. Engineering Analysis
* **Thermal Modeling:** Simulates brake disc heating and cooling using Newton's Law of Cooling.
* **Energy Efficiency:** Analyzes power consumption vs. regenerative braking (energy recovery).
* **Reporting:** Generates detailed 2D engineering plots and Excel/CSV reports for post-simulation analysis.


---

## 🛠️ How to Run

1.  **Clone the Repository**
    ```bash
    git clone [https://github.com/harunkkorkmaz/Marmaray_Analysis.git]
    ```
2.  **Open MATLAB**
    Navigate to the project folder.
3.  **Run the Main Script**
    Open `Marmaray_Grand_Final.m` and press **F5** (Run).
    * *Note: The simulation is set to 'Slow Motion' by default for better visualization.*

## 📂 Project Structure

* `Marmaray_Grand_Final.m`: The main source code containing the physics engine and visualization.
* `Marmaray_Engineering_Report.png`: Sample output of the 2D analysis.
* `README.md`: Project documentation.

## 🧮 Mathematical Models Used

The simulation relies on Newton's Second Law of Motion for longitudinal train dynamics:

$$ F_{traction} = m \cdot a + F_{aero} + F_{gradient} + F_{rolling} $$

Where:
* **Gradient Resistance:** $F_{g} = m \cdot g \cdot \sin(\theta)$ (Crucial for the tunnel section)
* **Aerodynamic Drag:** $F_{aero} = 0.5 \cdot \rho \cdot v^2 \cdot C_d \cdot A$

## 👨‍💻 Author

**Harun Kıvanç Korkmaz**
* Mechanical Technician Student | Gaziantep University
* Focus: System Dynamics, Simulation, and Automotive Engineering.
* [LinkedIn Profile](www.linkedin.com/in/harunkivanckorkmaz)

---

*This project is open-source and available under the MIT License.*
