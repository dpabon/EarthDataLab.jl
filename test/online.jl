using CABLAB
using Base.Test

using OnlineStats
c=RemoteCube()

d = getCubeData(c,variable="air_temperature_2m",longitude=(30,31),latitude=(50,51),
              time=(DateTime("2002-01-01"),DateTime("2008-12-31")))
oo=mapCube(Mean,d)

oo2=mapCube(Mean,d,by=(LatAxis,))

d2=readCubeData(d)

@test_approx_eq mean(d2.data) oo.data[1]
@test_approx_eq mean(d2.data,(1,3))[:] oo2.data

srand(1)
mask=CubeMem(d2.axes,rand(1:10,size(d2.data)),zeros(UInt8,size(d2.data)),Dict("labels"=>Dict(i=>string(i) for i=1:10)))
mask2=CubeMem(d2.axes[1:2],rand(1:10,4,4),zeros(UInt8,4,4),Dict("labels"=>Dict(i=>string(i) for i=1:10)))

oogrouped = mapCube(Mean,d2,by=(mask,))
@test isa(oogrouped.axes[1],CategoricalAxis{String,:Label})

oogrouped2 = mapCube(Mean,d2,by=(mask2,))

for k=1:10
  know = findfirst(j->j==string(k),oogrouped2.axes[1].values)
  @test_approx_eq oogrouped.data[know] mean(d2.data[mask.data.==k])

  i=find(mask2.data.==k)

  if length(i) > 0
    i1,i2=ind2sub((4,4),i)
    dhelp=Float32[]
    for (j1,j2) in zip(i1,i2)
      append!(dhelp,d2.data[j1,j2,:])
    end
    @test_approx_eq mean(dhelp) oogrouped2.data[know]
  end
end
