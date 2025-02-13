using MicroSpice
using Documenter

DocMeta.setdocmeta!(MicroSpice, :DocTestSetup, :(using MicroSpice); recursive=true)

makedocs(;
    modules=[MicroSpice],
    authors="Ted Dunning",
    sitename="MicroSpice.jl",
    format=Documenter.HTML(;
        canonical="https://tdunning.github.io/MicroSpice.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/tdunning/MicroSpice.jl",
    devbranch="main",
)
