using SafeTestsets


@safetestset CombinedNextReactionSmoke = "combinednext reaction does basic things" begin
    using Distributions
    using Random
    using Fleck: CombinedNextReaction, next, enable!, disable!

    rng = MersenneTwister(349827)
    for i in 1:100
        sampler = CombinedNextReaction{String,Float64}()
        @test next(sampler, 3.0, rng)[2] === nothing
        enable!(sampler, "walk home", Exponential(1.5), 0.0, 0.0, rng)
        @test next(sampler, 3.0, rng)[2] == "walk home"
        enable!(sampler, "run", Gamma(1, 3), 0.0, 0.0, rng)
        @test next(sampler, 3.0, rng)[2] ∈ ["walk home", "run"]
        enable!(sampler, "walk to sandwich shop", Weibull(2, 1), 0.0, 0.0, rng)
        @test next(sampler, 3.0, rng)[2] ∈ ["walk home", "run", "walk to sandwich shop"]
        disable!(sampler, "walk to sandwich shop", 1.7)
        @test next(sampler, 3.0, rng)[2] ∈ ["walk home", "run"]
    end
end

@safetestset CombinedNextReaction_interface = "CombinedNextReaction basic interface" begin
    using Fleck
    using Distributions
    using Random: Xoshiro

    sampler = CombinedNextReaction{Int64,Float64}()
    rng = Xoshiro(123)

    @test length(sampler) == 0
    @test length(keys(sampler)) == 0
    @test_throws KeyError sampler[1]
    @test keytype(sampler) <: Int64

    for (clock, when_fire) in [(1, 7.9), (2, 12.3), (3, 3.7), (4, 0.00013), (5, 0.2)]
        enable!(sampler, clock, Dirac(when_fire), 0.0, 0.0, rng)
    end

    @test length(sampler) == 5
    @test length(keys(sampler)) == 5
    @test sampler[1] == 7.9

    disable!(sampler, 1, 0.0)

    @test_throws BoundsError sampler[1]
    @test sampler[2] == 12.3

end
