using Plots
using JSON


function readJSON(_file::String)
    println(".read")
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
        return ne,x0,y0
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
    println(".DEM")
    # read input file
    N = 600
    h = 0.00004
    ne, x0, y0 = readJSON(_file)
    ndofs = 2*ne
    raio = 1.0
    mass = 7850.0
    kspr = 210000000000.0
    conect = [ 
        2    2    4    0    0
        3    1    3    5    0
        2    2    6    0    0
        3    5    1    7    0
        4    4    6    2    8
        3    5    3    9    0
        3    8    4   10    0
        4    7    9    5   11
        3    8    6   12    0
        3   11    7   13    0
        4   10   12    8   14
        3   11    9   15    0
        3   14   10   16    0
        4   13   15   11   17
        3   14   12   18    0
        2   17   13    0    0
        3   16   18   14    0
        2   17   15    0    0    ]
    F = [
     0.00000     0.00000
     0.00000     0.00000
     0.00000     0.00000
     0.00000     0.00000
     0.00000     0.00000
     0.00000     0.00000
     0.00000     0.00000
     0.00000     0.00000
     0.00000     0.00000
     0.00000     0.00000
     0.00000     0.00000
     0.00000     0.00000
     0.00000     0.00000
     0.00000     0.00000
     0.00000     0.00000
     -1000.0     0.00000
     -1000.0     0.00000
     -1000.0     0.00000]
    restrs = [
        1   1
        1   1
        1   1
        0   0
        0   0
        0   0
        0   0
        0   0
        0   0
        0   0
        0   0
        0   0
        0   0
        0   0
        0   0
        0   0
        0   0
        0   0]
    F = reshape(transpose(F),(ndofs,1))
    restrs = reshape(transpose(restrs),(ndofs,1))
        
    @show ne
    #@show x0
    #@show y0
    #@show conect
    #@show F
    #@show restrs

    u = zeros(Float64,ndofs,1)
    v = zeros(Float64,ndofs,1)
    a = zeros(Float64,ndofs,1)
    res = zeros(Float64,N)

    fi = zeros(Float64,ndofs,1)
    #@show fi
    a .= (F .- fi)./mass    
    for i = 1:N
        v .+= a .* (0.5*h)
        u .+= v .* h
        # contato
        fi .= 0.0
        for j = 1:ne
            if (restrs[2*j-1] == 1)
                u[2*j-1] = 0.0
            end
            if (restrs[2*j] == 1)
                u[2*j] = 0.0
            end
            xj = x0[j] + u[2*j-1]
            yj = y0[j] + u[2*j]
            for index = 1:conect[j,1]
                k = conect[j,index+1]
                xk = x0[k] + u[2*k-1]
                yk = y0[k] + u[2*k]
                dX = xj-xk
                dY = yj-yk
                di = sqrt(dX*dX+dY*dY)
                d2 = (di - 2*raio)
                dx = d2*dX/di
                dy = d2*dY/di
                fi[2*j-1] += kspr*dx
                fi[2*j] += kspr*dy
            end
        end
        a .= (F .- fi)./mass
        v .+= a .* (0.5*h)
        # plot
        res[i] = u[33]
    end
    outputRes(res)
    #@show res
    x = 1:N
    plot(x,res)
end

if length(ARGS) == 1
    main(ARGS[1])
end