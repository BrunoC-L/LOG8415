from pyspark import SparkConf, SparkContext
from os import remove, removedirs, listdir

VALUE_DIRECT_FRIEND = 0
VALUE_COMMON_FRIEND = 1

# parse a line of the txt file such as '0\t1,2,3,4,5\n' to (0,[1,2,3,4,5])
def parse_line(line):
    # split to separate user and friends
    array = line.split()
    user = int(array[0])
    hasFriends = len(array) > 1 and len(array[1]) > 0
    if hasFriends: 
        # convert csv to list of int
        friends = list(map(int, array[1].split(',')))
        return (user, friends)
    else :
        return (user, [])

# # parse a line of the txt file to an array like (0,[1,2,3,4,5,...])
# def parse_line(line):
#     array = line.split()
#     # first number is the user
#     user = int(array[0])
#     # no other number means there are no friends
#     if len(array) == 1 : 
#         friends = []
#     # all numbers after user are friends' user
#     else :
#         # convert to list of int
#         friends = list(map(int, array[1:][0].split(',')))

#     return (user, friends)

# make connection between user and all friend, and between all his friend and specify if there are friend or not with 0 or 1 flag
# output : [((0,1),0), ((0,2),1), ....] --> users 0 and 1 are friends and users 0 and 2 have a mutual friend
def create_friend_connection(user, friends):
    list_connections = []
    # add friend connections
    for friend in friends:
        # need to order the users_id in key
        key = (user, friend) if user < friend else (friend, user)
        list_connections.append((key, VALUE_DIRECT_FRIEND))

    # add connection between user's friends
    n = len(friends)
    for i, friend in enumerate(friends):
        for j in range(i + 1, n):
            otherFriend = friends[j]
            # need to order the users_id in key
            key = (friend, otherFriend) if friend < otherFriend else (otherFriend, friend)
            list_connections.append((key, VALUE_COMMON_FRIEND))
    
    return list_connections

# https://github.com/JaceyPenny/pyspark-friend-recommendation/blob/master/friend-recommendation.py
def mutual_friend_count_to_recommendation(connection, count):
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

    friend_0 = connection[0]
    friend_1 = connection[1]

    recommendation_0 = (friend_0, (friend_1, count))
    recommendation_1 = (friend_1, (friend_0, count))

    return [recommendation_0, recommendation_1]

def aBetterThanB(recA, recB):
    # prefer larger friend counter ([1]) but if equal smaller user_id ([0])
    return recA[1] > recB[1] or (recA[1] == recB[1] and recA[0] < recB[0])

def insert(recs, rec):
    if len(recs) < 10:
        recs += [rec]
    else: # out of space, shuffle (insertion sort except the smallest element is removed)
        for i in range(10):
            if aBetterThanB(rec, recs[i]):
                # shuffle [i, 8] to [i + 1, 9]
                for j in range(9, i, -1):
                    recs[j] = recs[j - 1]
                recs[i] = rec
                break


def recommendation_to_sorted_truncated(recs):
    # recommendations are sorted from best to worst
    recommendations = []
    for rec in recs:
        if len(recommendations) == 0 or aBetterThanB(rec, recs[-1]):
            insert(recommendations, rec)
    return [user_id for user_id, n_friends in recommendations]

def spark_run():
    # TODO remove refs to SHORT for release
    SHORT=True

    # Initialize spark configuration and context
    conf = SparkConf().set("spark.executor.cores", 4).set("spark.executor.instances", 4)
    sc = SparkContext(conf=conf)

    # Read from text file, split each line into "words" by any whitespace (i.e. empty parameters to string.split())
    fileLoc = 'soc-LiveJournal1Adj.txt'
    if SHORT:
        fileLoc = 'soc-LiveJournal1Adj-short.txt'
    print(fileLoc)
    lines = sc.textFile(fileLoc)

    # Map each line to the form: (user_id, [friend_id_0, friend_id_1, ...])
    # Map each "friend ownership" to multiple instances of ((user_id, friend_id), VALUE).
    # VALUE = 0 indicates that user_id and friend_id are already friends.
    # VALUE = 1 indicates that user_id and friend_id are not friends.

    def our_mapper(line):
        return create_friend_connection(*parse_line(line))
    
    friend_edges = lines.flatMap(our_mapper)
    friend_edges.cache()
    
    # Filter all pairs of users that are already friends, then sum all the "1" values to get their mutual friend count.
    mutual_friend_counts = friend_edges.groupByKey() \
        .filter(lambda edge: 0 not in edge[1]) \
        .map(lambda edge: (edge[0], sum(edge[1])))
    mutual_friend_counts.cache()

    # Create the recommendation objects, group them by key, then sort and truncate the recommendations to the 10 most highly recommended.
    recommendations = mutual_friend_counts \
        .flatMap(lambda conn_count: mutual_friend_count_to_recommendation(*conn_count)) \
        .groupByKey() \
        .map(lambda edge: (edge[0], recommendation_to_sorted_truncated(list(edge[1]))))

    outLoc = "./result-network-problem"
    if SHORT:
        outLoc += '-short'
    print(outLoc)

    try:
        # remove spark output location in case it has been used
        for f in listdir(outLoc):
            remove(outLoc + '/' + f)
        removedirs(outLoc)
    except:
        # would happen if the location didn't exist, which is fine
        pass

    recommendations.saveAsTextFile(path=outLoc)
    sc.stop()

spark_run()
