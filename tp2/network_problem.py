
from pyspark import SparkConf, SparkContext

#parse a line of the txt file to an array like (0,[1,2,3,4,5,...])
def parse_line(line):

    array = line.split()
    #first number is the user
    user = int(array[0])
    #no other number means there are no friends
    if len(array) == 1 : 
        friends = []
    #all numbers after user are friends' user
    else :
        #convert to list of int
        friends = list(map(int,array[1:][0].split(',')))

    return((user,friends))


#make connection between user and all friend, and between all his friend and specify if there are friend or not with 0 or 1 flag
#output : [ ((0,1),0), ((0,2),1), ....] --> users 0 and 1 are friends ;and users 0 and 2 have a mutual friend

def create_friend_connection(array):

    list_connections = []
    user = array[0]
    friends = array[1]

    #add friend connection of the user mapped with 0
    for friend in friends:
        #need to order the users_id in key in a determinated order (need be the same all the way so we can reduce by these key after)
        if friend>user:
            key = (user,friend)
        else:
            key = (friend,user)
        
        list_connections.append((key,0))

    #add connection between user's friends (=mutual friend connection that we map with 1)
    n= len(friends)
    for i in range(0,n):
        for j in range(i+1,n):
            #print(friends[i],friends[j])
            if friends[i]>friends[j]:
                key = (friends[j],friends[i])
            else:
                key = (friends[i],friends[j])
               
            list_connections.append((key,1))
    
    return(list_connections)


def our_mapper(line):
    return(create_friend_connection(parse_line(line)))


#toute cette partie vient de https://github.com/JaceyPenny/pyspark-friend-recommendation/blob/master/friend-recommendation.py

#pas encore bien compris pour la modifier
def mutual_friend_count_to_recommendation(m):
    """
    Maps a "mutual friend count" object to two distinct recommendations. The value
    ``((0, 1), 21)`` encodes that users 0 and 1 share 21 mutual friends. This means that user 1 should be recommended
    to user 0 AND that user 0 should be recommended to user 1. For every input to this function, two "recommendations"
    will be returned in a List.
    A "recommendation" has the following form::
        (user_id_0, (recommended_user, mutual_friends_count))
    :param m: a mutual friend count item
    :return: List[Tuple[int, Tuple[int, int]]] two recommendation items
    """
    connection = m[0]
    count = m[1]

    friend_0 = connection[0]
    friend_1 = connection[1]

    recommendation_0 = (friend_0, (friend_1, count))
    recommendation_1 = (friend_1, (friend_0, count))

    return [recommendation_0, recommendation_1]


def recommendation_to_sorted_truncated(recs):
    if len(recs) > 1024:
        # Before sorting, find the highest 10 elements in recs (if log(len(recs)) > 10)
        # This optimization runs in O(n), where n is the length of recs. This is so that sorting the best 10
        # recommendations can run in constant time. Otherwise, sorting the whole list would run in O(n lgn). 
        # As long as n > 1024 (or, in other words, lg(n) > 10), this is faster.

        max_indices = []

        for current_rec_number in range(0, 10):
            current_max_index = 0
            for i in range(1, len(recs)):
                rec = recs[i]
                if rec[1] >= recs[current_max_index][1] and i not in max_indices:
                    current_max_index = i

            max_indices.append(current_max_index)

        recs = [recs[i] for i in max_indices]

    # Sort first by mutual friend count, then by user_id (for equal number of mutual friends between users)
    recs.sort(key=lambda x: (-x[1], x[0]))

    # Map every [(user_id, mutual_count), ...] to [user_id, ...] and truncate to 10 elements
    return list(map(lambda x: x[0], recs))[:10]



#---------------------------------------------------------------
#PySpark run
#---------------------------------------------------------------

# Initialize spark configuration and context
conf = SparkConf()
sc = SparkContext(conf=conf)

# Read from text file, split each line into "words" by any whitespace (i.e. empty parameters to string.split())
lines = sc.textFile('soc-LiveJournal1Adj.txt')

# Map each line to the form: (user_id, [friend_id_0, friend_id_1, ...])
# Map each "friend ownership" to multiple instances of ((user_id, friend_id), VALUE).
# VALUE = 0 indicates that user_id and friend_id are already friends.
# VALUE = 1 indicates that user_id and friend_id are not friends.
friend_edges =lines.flatMap(our_mapper)
friend_edges.cache()

# Filter all pairs of users that are already friends, then sum all the "1" values to get their mutual friend count.
mutual_friend_counts = friend_edges.groupByKey() \
    .filter(lambda edge: 0 not in edge[1]) \
    .map(lambda edge: (edge[0], sum(edge[1])))

# Create the recommendation objects, group them by key, then sort and truncate the recommendations to the 10 most
# highly recommended.
recommendations = mutual_friend_counts.flatMap(mutual_friend_count_to_recommendation) \
    .groupByKey() \
    .map(lambda m: (m[0], recommendation_to_sorted_truncated(list(m[1]))))

# Save to output directory, end context

#mettre le bon path pour sauvegarder
recommendations.saveAsTextFile(path="")
sc.stop()