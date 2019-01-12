defmodule CNode do
  use GenServer
  require Logger
  def init([i,nodeid,listOfNodes,listOfKeys]) do
    m = 20
    #IO.puts "Started #{nodeid} successfully "
    inOrderListOfNodes = :lists.sort(listOfNodes)

    fingerTable = build_finger(inOrderListOfNodes,m,nodeid)
    currindex = Enum.find_index(inOrderListOfNodes,fn x -> x == nodeid end)
    previousNode = elem(Enum.fetch(inOrderListOfNodes,currindex-1),1)

    keyTable = Enum.filter(listOfKeys, fn x -> x <= nodeid and x > previousNode end)


    {:ok,{i,nodeid,m,listOfNodes,listOfKeys,fingerTable,keyTable}}

  end


  def build_finger(inOrderListOfNodes,m,nodeid) do
    fingerTable = for i <- 0..m-1 do
                        findFinger = rem(nodeid + round(:math.pow(2,i)),:math.pow(2,m) |> round)
                        if(findFinger > List.last(inOrderListOfNodes)) do
                          neighbour_num_i = List.first(inOrderListOfNodes)
                          neighbour_num_i
                        else
                          neighbour_num_i = Enum.find(inOrderListOfNodes, fn x -> x >= findFinger end)
                          neighbour_num_i
                        end
                  end
    fingerTable
  end



   def find_successor(nodeid, selectedKey) do
    # IO.puts "In findsuccesor for #{nodeid}"
     serverstate = GenServer.call(:"#{nodeid}", :getinfo)
     fingertab = elem(serverstate,5)
     m = elem(serverstate,2)
    #  IO.puts "Fingertable for #{nodeid}"
    #  IO.inspect fingertab

    if(nodeid < selectedKey and selectedKey <= Enum.at(fingertab,0)) do
       retval = Enum.at(fingertab,0)
      #  IO.puts "Succesor is #{retval}"
       :ets.update_counter(:hopreg, "hopcount", {2,1})
       retval
    else
      # IO.puts "In else"
      newnode = closest_preceeding_node(nodeid,selectedKey,m)

      serverstate1 = GenServer.call(:"#{newnode}", :getinfo)
      # fingertab1 = elem(serverstate1,5)
      # m = elem(serverstate1,2)
      mykeytable1 = elem(serverstate1,6)
      # nodelist1 = elem(serverstate1,3)
      if(Enum.member?(mykeytable1,selectedKey)) do
        retval=newnode
        retval
      else
      retval = find_successor(newnode,selectedKey)
      # IO.puts "Now retval #{retval}"
      retval
      end
  end
end


  def closest_preceeding_node(gotnodeid,selectedKey,m) do
    serverstate = GenServer.call(:"#{gotnodeid}", :getinfo)
    fingertab = elem(serverstate,5)
    # m = elem(serverstate,2)
    mykeytable = elem(serverstate,6)
    nodelist = elem(serverstate,3)
    if(Enum.member?(mykeytable,selectedKey)) do
      sortlist = :lists.sort(nodelist)
      nodeindex = Enum.find_index(sortlist, gotnodeid)
      closest   = Enum.fetch(sortlist,nodeindex-1)
      closest
    else
    closest = checktable(gotnodeid,selectedKey,fingertab,m-1)
    closest
    end
  end

  def checktable(gotnodeid,selectedKey,fingertab,index) when index >=0 do
    serverstate = GenServer.call(:"#{gotnodeid}", :getinfo)
    # fingertab = elem(serverstate,5)
    # m = elem(serverstate,2)
    mykeytable = elem(serverstate,6)
    nodelist = elem(serverstate,3)
    if(Enum.member?(mykeytable,selectedKey)) do
      sortlist = :lists.sort(nodelist)
      nodeindex = Enum.find_index(sortlist, gotnodeid)
      closest   = Enum.fetch(sortlist,nodeindex-1)
      closest
    else
    if(gotnodeid < Enum.at(fingertab,index) and Enum.at(fingertab,index) < selectedKey) do
      :ets.update_counter(:hopreg, "hopcount", {2,1})
      Enum.at(fingertab, index)
    else
      checktable(gotnodeid,selectedKey,fingertab,index-1)

    end
  end
  end

  def checktable(gotnodeid,selectedKey,fingertab,index) when index < 0 do
    serverstate = GenServer.call(:"#{gotnodeid}", :getinfo)
    # fingertab = elem(serverstate,5)
    # m = elem(serverstate,2)
    mykeytable = elem(serverstate,6)
    nodelist = elem(serverstate,3)
    if(Enum.member?(mykeytable,selectedKey)) do
      sortlist = :lists.sort(nodelist)
      nodeindex = Enum.find_index(sortlist, gotnodeid)
      closest   = Enum.fetch(sortlist,nodeindex-1)
      closest
    else
      # :ets.update_counter(:hopreg, "hopcount", {2,1})
      Enum.at(fingertab,0)
    end
  end

  def fix_finger(nodeid,selectedKey) do
   GenServer.cast(:"#{nodeid}", {:retrieve, selectedKey, nodeid})
  end

  def handle_call(:getinfo,_from,state) do
    {:reply,state,state}
  end

  def handle_cast(:found, state) do
    IO.puts "found what you requested **********************************"
    {:noreply, state}
  end


  def join({:retrieve, selectedKey, sourceNode}, state) do
    {i,nodeid,m,listOfNodes,listOfKeys,fingerTable,keyTable}=state


    if(Enum.member?(keyTable, selectedKey)) do

      GenServer.cast(:"#{sourceNode}", :found)
    else

      checktable(fingerTable,m-1,selectedKey,sourceNode)
    end
    {:noreply, state}
  end

end

