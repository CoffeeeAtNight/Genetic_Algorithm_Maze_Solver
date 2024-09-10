import std/random
import std/algorithm
import std/os

type
  Chromosome {.pure.} = enum
    UP = 00, RIGHT = 01, DOWN = 10, LEFT = 11

  Agent = object
    x: int
    y: int
    genome: seq[Chromosome]
    fitness: float

const
  START_POS_X: int = 1
  START_POS_Y: int = 6
  GOAL_POS_X: int = 3
  GOAL_POS_Y: int = 4
  ELITE_SIZE: int = 25
  MUTATION_RATE: float = 0.02
  GENOME_STRING_LENGTH: int = 24
  AMOUNT_GENERATIONS: int = 100
  MAZE_WIDTH: int = 8
  MAZE_HEIGHT: int = 8
  POPULATION_SIZE: int = 50

var
  maze: array[8, array[8, int]]
  population: seq[Agent]

# 0 Paths   1 Walls   2 Goal  
maze = [
  [1, 1, 1, 1, 1, 1, 1, 1],
  [1, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 1, 1, 1, 0, 1, 1],
  [1, 0, 0, 2, 1, 0, 0, 1],
  [1, 0, 1, 1, 1, 0, 1, 1],
  [1, 1, 1, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 1, 1, 0, 1],
  [1, 1, 1, 1, 1, 1, 1, 1]
]


proc pickRandChromosomeInstruction(): Chromosome =
  let randNum = rand(3)
  case randNum:
    of 0: return Chromosome.UP
    of 1: return Chromosome.RIGHT
    of 2: return Chromosome.DOWN
    of 3: return Chromosome.LEFT
    else: discard


proc generateRandomGenome(): seq[Chromosome] =
  var genome: seq[Chromosome]
  for i in countup(0, GENOME_STRING_LENGTH):
    genome.add(pickRandChromosomeInstruction())
  return genome


proc initAgent(): Agent =
  var agent = Agent(
    x: START_POS_X,
    y: START_POS_Y,
    fitness: 0.0,
    genome: generateRandomGenome()
  )

  return agent


proc initPopulation() = 
  for i in 0 ..< POPULATION_SIZE:
    population.add(initAgent())


proc evaluateFitness() =
  for i in 0 ..< population.len:
    population[i].fitness = cast[float](abs(population[i].x - GOAL_POS_X) + abs(population[i].y - GOAL_POS_Y))


proc selectBestPerformers(): seq[Agent] =
  # Sort population by fitness score
  population.sort(proc (a, b: Agent): int =
    cmp(b.fitness, a.fitness))

  # Select the "elite agents"
  return population[0 ..< ELITE_SIZE]


proc singlePointCrossoverAgents(parentAgentOne: Agent, parentAgentTwo: Agent): (Agent, Agent) =
  let genomeLength = parentAgentOne.genome.len
  let crossoverPoint = rand(genomeLength - 1) 

  # Split the genomes of both parents at the crossover point and create two new genomes
  let childOneGenome = parentAgentOne.genome[0 ..< crossoverPoint] & parentAgentTwo.genome[crossoverPoint ..< genomeLength]
  let childTwoGenome = parentAgentTwo.genome[0 ..< crossoverPoint] & parentAgentOne.genome[crossoverPoint ..< genomeLength]

  # Create new child agents with the generated genomes
  let childOne: Agent = Agent(genome: childOneGenome)
  let childTwo: Agent = Agent(genome: childTwoGenome)

  return (childOne, childTwo)


proc breedEliteChildren(eliteAgents: seq[Agent]): seq[Agent] =
  var 
    eliteChildren: seq[Agent] = @[]
    i = 0

  while i < eliteAgents.len - 1:
    let (child1, child2) = singlePointCrossoverAgents(eliteAgents[i], eliteAgents[i+1])
    eliteChildren.add(child1)
    eliteChildren.add(child2)
    i += 2 

  return eliteChildren

proc mutateGene(gene: Chromosome): Chromosome =
  let allGenes = [Chromosome.UP, Chromosome.RIGHT, Chromosome.DOWN, Chromosome.LEFT]
  var newGene: Chromosome
  while true:
    newGene = allGenes[rand(allGenes.len - 1)]  # Pick a random gene from the list
    if newGene != gene:
      break
  return newGene


proc mutateEliteGivenChildrenChromosomes(children: ptr seq[Agent]) =
  for i in 0 ..< children[].len:
    for j in 0 ..< GENOME_STRING_LENGTH:
      if rand(1.0) < MUTATION_RATE:
        # Mutate the gene at position i (this could be flipping a bit or changing a value)
        children[i].genome[j] = mutateGene(children[i].genome[j])


# When 0 = Can move | When 1 = Wall | When 2 = Reached goal
proc startAgentMove(agent: ptr Agent, chromosomeNum: int) =
  var 
    currentInstruction: Chromosome = agent.genome[chromosomeNum]
    posAfterUpMove = if agent[].y > 0: maze[agent[].y - 1][agent[].x] else: 1
    posAfterRightMove = if agent[].x < MAZE_WIDTH - 1: maze[agent[].y][agent[].x + 1] else: 1
    posAfterDownMove = if agent[].y < MAZE_HEIGHT - 1: maze[agent[].y + 1][agent[].x] else: 1
    posAfterLeftMove = if agent[].x > 0: maze[agent[].y][agent[].x - 1] else: 1

  case currentInstruction:
    of Chromosome.UP:
      if posAfterUpMove == 1:
        return
      elif posAfterUpMove == 0:
        dec(agent[].y)
      else:
        agent[].fitness += 100
        echo "A agent reached the goal!"
        return
    of Chromosome.RIGHT:
      if posAfterRightMove == 1:
        return
      elif posAfterRightMove == 0:
        inc(agent[].x)
      else: 
        agent[].fitness += 100
        echo "A agent reached the goal!"
        return
    of Chromosome.DOWN:
      if posAfterDownMove == 1:
        return
      elif posAfterDownMove == 0:
        inc(agent[].y)
      else: 
        agent[].fitness += 100
        echo "A agent reached the goal!"
        return
    of Chromosome.LEFT:
      if posAfterLeftMove == 1:
        return
      elif posAfterLeftMove == 0:
        dec(agent[].x)
      else: 
        agent[].fitness += 100
        echo "A agent reached the goal!"
        return


proc displayMaze() =
  # Loop through the maze dimensions and print each cell
  for y in countdown(MAZE_HEIGHT - 1, 0):
    for x in 0 ..< MAZE_WIDTH:
      var charToPrint: string
      case maze[y][x]:
        of 1: charToPrint = "#"  # Wall
        of 0: charToPrint = " "  # Path
        of 2: charToPrint = "G"  # Goal
        else: discard

      # Check if any agent is on this position
      for agent in population:
        if agent.x == x and agent.y == y:
          charToPrint = "■"
          break

      # Print character with space for better visibility
      stdout.write(charToPrint & " ")
    stdout.write("\n")
  stdout.write("\n")


proc clearScreen() =
  # Clear the screen for each new rendering
  stdout.write("\x1B[2J")


# Modified moveAgents to display the maze clearly
proc moveAgents() =
  for chromosomeNum in 0 ..< GENOME_STRING_LENGTH:
    for agentNum in 0 ..< population.len:
      startAgentMove(addr population[agentNum], chromosomeNum)

    # Clear screen and display the maze after each chromosome execution
    clearScreen()
    displayMaze()
    sleep(4000)  # Slow down to watch the movement


proc resetAgentsParameters() =
  echo "[i] RESETTING AGENTS"
  for i in 0 ..< population.len:
    population[i].x = START_POS_X
    population[i].y = START_POS_Y
    population[i].fitness = 0.0

proc updatePopulation(newGeneration: seq[Agent]) =
  # Replace the current population with new generation
  population.setLen(0)  # Clear the current population
  population.add(newGeneration)  # Add the new generation


proc showResults() =
  echo "Done!"


proc main() =
  var generation = 0

  # Initializes 50 Agents for training
  initPopulation()

  # Render loop
  while generation < AMOUNT_GENERATIONS:
    echo "Generation Nr. " & $generation & " started..."

    # Move Agents to next position
    moveAgents()

    # Calculate fitness of agents
    evaluateFitness()

    # Filter out 25 elite agents of 50 total
    var eliteAgents = selectBestPerformers()

    # Breed elite children
    var eliteChildren = breedEliteChildren(eliteAgents)

    # Mutate agents chromosomes with a chance of 0.02%
    mutateEliteGivenChildrenChromosomes(addr eliteChildren)

    # Replace the current population with new generation
    updatePopulation(eliteChildren)

    # Reset position and fitness
    resetAgentsParameters()

    # Jump to next generation
    inc(generation)


  # Show results
  showResults()
  sleep(10000)

# Here we goooo!
main()