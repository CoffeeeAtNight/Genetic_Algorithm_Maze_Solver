# 🧬 Genetic Algorithm Maze Solver

### A simple genetic algorithm project that evolves agents to navigate a 2D maze! 🚀

---

## Overview 🎯

This project implements a **genetic algorithm (GA)** to evolve agents that can find their way through a maze. The agents start with random movements, and through natural selection, crossover, and mutation, they gradually improve their ability to reach the goal.

Key Features:
- **Genetic Algorithm Core**: Includes selection, crossover, and mutation mechanics.
- **Maze Representation**: The maze is represented as a 2D grid with walls, paths, and a goal.
- **Real-time Visualization**: Watch agents as they evolve in the maze with a simple ASCII representation.
- **Elite Selection**: Top-performing agents are selected as the basis for the next generation.

---

## How It Works 🧠

1. **Initialization**:
   - Agents are created with a random genome (sequence of moves: up, down, left, right).
   - Agents are placed at the start position in the maze.

2. **Fitness Evaluation**:
   - Each agent’s fitness is determined by how close it gets to the goal. The closer, the better the fitness.

3. **Evolution Process**:
   - **Selection**: The top-performing agents (elite agents) are selected to reproduce.
   - **Crossover**: Two parents’ genomes are combined at a random point to create offspring.
   - **Mutation**: Some offspring may experience small random changes to their genome to introduce variation.

4. **Next Generation**:
   - The new generation replaces the old one, and the process repeats until agents successfully reach the goal or the set number of generations is reached.

---

## Maze Layout 🗺️

The maze is represented as an 8x8 grid:
- **#**: Wall
- **A**: Agent
- **G**: Goal
- **(Blank Space)**: Path

---

## Todo:

- **Fix problem where generation stops after some time**
- **Improve fitness function to prevent local maximum**
- **Integrate OpenGL to better represent generations**

---

![image](https://github.com/user-attachments/assets/e8d83414-d388-45f2-ac5b-3571967c034d)
