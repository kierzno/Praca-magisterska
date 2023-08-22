using DelimitedFiles
using StatsBase
using Distributions

#losowanie z rozkładu jednostajnego
function uniform_draw(N)
    table = rand(Uniform(0,1),N)
    return table
end

#parametry modelu
N = 100
M = N
lambda = 1
gamma = 0
primary = 0
secondary = 0
delta = 0

#parametry symulacji
steps = 1000
freq = 0
rep_from = 1
rep_to = 100
reps = rep_to-rep_from+1

#zmienne pomocnicze
time_s = 0

#tablica z oszczędnościami
function savings_table(N, lambda)
    if lambda < 1
        savings = [lambda for n=1:N]
    else
        savings = uniform_draw(N)
        println(savings)
    end
end


education = []
skill = [1 for n=1:N]
total = []

#losowanie agentów
function random_agent(N, money, gamma)
    prob = [money[n] ^ gamma for n=1:N]
    if gamma == 0
        agent1 = rand(1:N)
        agent2 = rand(1:N)

        while agent1 == agent2
            agent2 = rand(1:N)
        end
    else
        agent1 = sample(1:N, Weights(prob))
        agent2 = sample(1:N, Weights(prob))
        while agent1 == agent2
            agent2 = sample(1:N, Weights(prob))
        end
    end
    return agent1, agent2
end

#symulacja
for i in 1:reps
    money = [N/M for n=1:N] #tablica z pieniędzmi
    savings = savings_table(N, lambda)
    for t in 1:steps
        for n in 1:N
            agent1, agent2 = random_agent(N, money, gamma)
            epsilon = rand()
            money_sum = (1-savings[agent1])*money[agent1] + (1-savings[agent2])*money[agent2]
            skill_ratio = skill[agent2] / skill[agent1]
            money[agent1] = savings[agent1]*money[agent1] + (epsilon ^ skill_ratio) * money_sum
            money[agent2] = savings[agent2]*money[agent2] + (1 - epsilon ^ skill_ratio) * money_sum
        end
    end
    append!(total, money)
    writedlm( "File.csv",  total, ',')
    println(i)
end


