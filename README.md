Readme


Group Information :
1.	Niraja Ganpule : UFID 17451951 
2.	Harshal Patil : UFID 55528581 

What is working ?

We have successfully implemented the paper on Chord :  A Scalable Peer to Peer lookup Protocol for Internet Applications. We have implemented the APIs in the paper to achieve scalable lookup of keys in a distributed environment in O(log N) time. The system makes sure that the total keys i.e. files get uniformly distributed among all the nodes,  Hence it ensures we have optimal load balancing. We have used consistent hashing technique to ensure the nodes and keys are uniformly distributed along the network. 

Largest network that we managed to solve:

The largest test we ran to simulate a chord network was of 10000 nodes and 10 num requests. The time it takes to compute the network and do all the lookups is considerable due to the time it takes to initialize such a huge network. Beyond this value my CPU runs out of heap space. 

Instructions :

Compile

In the project directory run the following command on the terminal  

mix escript.build

Run 

In the project directory run the following command on the terminal 

escript chord <numnodes> < numreq>

Example - escript chord 200 5


Results:

The average number of hops across all the requests made by all the nodes is displayed.

Example:

Input : escript chord 200 5

Output : Final average hop count : 4.173


