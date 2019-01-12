defmodule Logic do


  def start(numnodes,numreq) do


    m = 20

    listOfNodes = for i <- 0..numnodes-1 do

                hash = :crypto.hash(:sha,Integer.to_string(i)) |> Base.encode16 |> Integer.parse(16)
                nodeid = rem(elem(hash,0),trunc(:math.pow(2,m)))
                nodeid
                end



    listOfKeys = for _ <- 0..numnodes*5 do
                randomKey = :rand.uniform(:math.pow(2,m) |> round)
                hash = :crypto.hash(:sha,Integer.to_string(randomKey)) |> Base.encode16 |> Integer.parse(16)
                hashedKey = rem(elem(hash,0),trunc(:math.pow(2,m)))
                hashedKey
              end

    for i <- 0..numnodes-1 do
                hash = :crypto.hash(:sha,Integer.to_string(i)) |> Base.encode16 |> Integer.parse(16)
                nodeid = rem(elem(hash,0),trunc(:math.pow(2,m)))
                GenServer.start_link(CNode,[i,nodeid,listOfNodes,listOfKeys],name: :"#{nodeid}")

    end

    :ets.new(:hopreg,[:set,:public,:named_table])
    :ets.insert(:hopreg, {"hopcount",0 })

    mypid = self()
    # IO.puts "Mypid"
    # IO.inspect mypid
    for i <- 0..numnodes-1 do

      _ = Task.start fn -> start_req(Enum.at(listOfNodes,i),mypid,numreq) end
     end

    # IO.puts "Before receive"
    for _ <- 0..((numnodes*numreq)-1) do
      receive do
        {:done} ->    nil #IO.puts " Done with hops"

      end
   end


  #  IO.inspect :ets.lookup(:hopreg, "hopcount")
   [h|_] = :ets.lookup(:hopreg, "hopcount")

   {_,hopc} = h
   average_hop = hopc/(numnodes*numreq)
   IO.puts "Final average hop count : #{average_hop}"

   :ets.delete(:hopreg)


  end

  def start_req(nodeid,pid,numreq) do
    currstate = GenServer.call(:"#{nodeid}",:getinfo)
    listOfKeys = elem(currstate, 4)
    m = elem(currstate, 2)

    listOfNodes = elem(currstate, 3)
    inOrderListOfNodes = :lists.sort(listOfNodes)

    for _ <- 0..numreq-1 do

          selectedKey = select_key(listOfKeys)
          if(selectedKey <= List.first(inOrderListOfNodes) or selectedKey > List.last(inOrderListOfNodes)) do
          _ =Enum.at(inOrderListOfNodes,0)
          :ets.update_counter(:hopreg, "hopcount", {2,(:math.log2(m)|>round)})
          # IO.puts "Final : #{succ}"
          else

          keytable = elem(currstate, 6)
          if(Enum.member?(keytable, selectedKey)) do
            _ = nodeid
          #  IO.puts "Final : #{succ}"
          else
            _ =CNode.find_successor(nodeid,selectedKey)
            # IO.puts "Final : #{succ}"
          end
        end
        # IO.puts "PID in start req"
        # IO.inspect pid
        send(pid,{:done})
      end
  end

  def select_key(listOfKeys) do
    selectedKey = Enum.random(listOfKeys)
    selectedKey
  end



end


























