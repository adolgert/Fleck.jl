using Fleck
using Documenter
using Literate

example_base = joinpath(dirname(@__FILE__), "src")
adliterate = [
        ("simple_board.jl", "mainloop"), ("distributions.jl", "distributions"), 
        ("constant_birth.jl", "constant_birth"), ("sir.jl", "sir")
    ]
for (source, target) in adliterate
    fsource, ftarget = joinpath.(example_base, [source, target])
    if !isfile("$(ftarget).md") || mtime(fsource) > mtime("$(ftarget).md")
        println("Literate of $source to $target")
        Literate.markdown(
            fsource,
            example_base,
            name=target,
            execute=true
            )
    end
end

makedocs(;
    modules=[Fleck],
    authors="Andrew Dolgert <adolgert@uw.edu>",
    repo="https://github.com/adolgert/Fleck.jl/blob/{commit}{path}#L{line}",
    sitename="Fleck.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        size_threshold_warn=2^17,
        canonical="https://adolgert.github.io/Fleck.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Guide" => [
            "guide.md",
            "mainloop.md",
            "distributions.md"
        ],
        "Manual" => [
            "Structure" => "objects.md",
            "background.md",
            "distrib.md",
            "Develop" => "develop.md",
            "samplers.md",
            "Vector Addition Systems" => "vas.md",
        ],
        "Examples" => [
            "Birth-death Process" => "constant_birth.md",
            "SIR Model" => "sir.md"
        ],
        "Reference" => "reference.md"
    ],
)

deploydocs(;
    repo="github.com/adolgert/Fleck.jl",
)
