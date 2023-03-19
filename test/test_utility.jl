# This module defines utility functions for the tests below.
# You have to put them into a module in order for them to be
# found within a @safetestset.
module SampleVAS
using Combinatorics
using Distributions
using Fleck
export sample_transitions, sample_sir, TrackerSampler, enable!, disable!
function sample_transitions()
    all = [
        -1  0  1  0  0;
         1 -1 -1 -1  1;
         0  1  0  1 -1
    ]
    take = -1 * (all .* (all .< 0))
    give = all .* (all .> 0)
    rates = Function[x -> Exponential(1.0) for x in 1:size(all, 2)]
    (take, give, rates)
end

# cnt is the number of individuals
# vector is cnt of S, cnt of I, cnt of R
function sample_sir(cnt)
    s = 0
    i = cnt
    r = 2 * cnt
    i_rate, r_rate = (0.9, 0.01)
    infection = collect(combinations(1:cnt, 2))
    recover = cnt
    # Rows are s individuals, i individuals, r individuals
    # Columns are infections, then recoveries.
    take = zeros(Int, 3 * cnt, 2 * length(infection) + recover)
    give = zeros(Int, 3 * cnt, 2 * length(infection) + recover)
    rates = Function[]
    idx = 0
    for (a, b) in infection
        idx += 1  # b infects a
        take[s + a, idx] = 1
        take[i + b, idx] = 1
        give[i + a, idx] = 1
        give[i + b, idx] = 1
        push!(rates, state -> Exponential(i_rate))
        idx += 1  # a infects b
        take[i + a, idx] = 1
        take[s + b, idx] = 1
        give[i + a, idx] = 1
        give[i + b, idx] = 1
        push!(rates, state -> Exponential(i_rate))
    end
    for c in 1:recover
        idx += 1
        take[i + c, idx] = 1
        give[r + c, idx] = 1
        push!(rates, state -> Exponential(r_rate))
    end
    (take, give, rates)
end

end
