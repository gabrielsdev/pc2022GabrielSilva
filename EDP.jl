using Plots
using JSON

function readJSON(_file::String)
    println("Lendo arquivo")
    open(_file,"r") do f
        data = JSON.parse(f)
        if haskey(data,"points")
            ne = size(data["points"])[1]
            x0 = Array{Float64}(undef,ne,1)
            y0 = Array{Float64}(undef,ne,1)
            for i=1:ne
                x0[i] = convert(Float64,data["points"][i][1])
                y0[i] = convert(Float64,data["points"][i][2])
            end
        end
        return ne,x0,y0 #Retorna a quantidade de pontos e coordenadas mapeados do arquivo para o código
    end
end

function outputRes(_res)
    dict = Dict()
    push!(dict,"resultado"=>_res)
    open("output.json","w") do f
        JSON.print(f,dict)
    end
end

function main(_file::String)
    conect = [0 0 5 2; #posição, ponto t1 não tem nada nem na esquerda e nem embaixo, mas em cima é o t5 e do lado direito é t2
    1 0 6 3;
    2 0 7 4;
    3 0 8 0;
    0 1 9 6;
    5 2 10 7;
    6 3 11 8;
    7 4 12 0;
    0 5 13 10;
    9 6 14 11;
    10 7 15 12;
    11 8 16 0;
    0 9 0 14;
    13 10 0 15;
    14 11 0 16;
    15 12 0 0]

    nn = size(conect,1)
    cc = [1 100;
    1 75;
    1 75;
    1 0;
    1 100;
    0 0;
    0 0;
    1 0;
    1 100;
    0 0;
    0 0;
    1 0;
    1 100;
    1 25;
    1 25;
    1 0]

    #Método das diferenças finitas
    a = zeros(Float64,nn,nn)
    b = zeros(Float64,nn,1)
    
    for e=1:nn
        if(cc[e,1] == 0)
            a[e,e] = -4
            for j=1:4
                a[e,conect[e,j]] = 1
            end
        else
            a[e,e] = 1
            b[e,1] = cc[e,2]
        end
    end

    x = a\b

    @show a
    @show b
    @show x
end

if length(ARGS) == 1
    main(ARGS[1])
end