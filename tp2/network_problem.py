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

# takes `(user0, user1), count` and returns [(user0, (user1, count)), (user1, (user0, count))]
def mutual_friend_count_to_recommendation(edge, count):
    user_0 = edge[0]
    user_1 = edge[1]
    return [(user_0, (user_1, count)), (user_1, (user_0, count))]

def aBetterThanB(recommendationA, recommendationB):
    # prefer larger friend counter ([1]) but if equal smaller user_id ([0])
    return recommendationA[1] > recommendationB[1] or (recommendationA[1] == recommendationB[1] and recommendationA[0] < recommendationB[0])

def insert(recommendations, recommendation):
    if len(recommendations) < 10:
        recommendations += [recommendation]
    else: # out of space, shuffle (insertion sort except the smallest element is removed)
        for i in range(10):
            if aBetterThanB(recommendation, recommendations[i]):
                # shuffle [i, 8] to [i + 1, 9]
                for j in range(9, i, -1):
                    recommendations[j] = recommendations[j - 1]
                recommendations[i] = recommendation
                return

def recommendation_to_sorted_truncated(recommendations):
    # recommendations are sorted from best to worst
    top10 = []
    for rec in recommendations:
        if len(top10) == 0 or aBetterThanB(rec, top10[-1]):
            insert(top10, rec)
    return [user_id for user_id, n_friends in top10]

def save(obj, loc):
    try:
        # remove spark output location in case it has been used
        for f in listdir(loc):
            remove(loc + '/' + f)
        removedirs(loc)
    except:
        # would happen if the location didn't exist, which is fine
        pass

    obj.saveAsTextFile(path=loc)

def spark_run():
    print('starting')
    # TODO remove refs to SHORT for release
    SHORT=False

    conf = SparkConf().set("spark.executor.cores", 4).set("spark.executor.instances", 4)
    sc = SparkContext(conf=conf)

    fileLoc = 'soc-LiveJournal1Adj.txt'
    if SHORT:
        fileLoc = 'soc-LiveJournal1Adj-short.txt'
    lines = sc.textFile(fileLoc)

    # friend edges are of shapes ((user_id1, user_id2), 0 or 1) with 0 meaning friends, 1 meaning mutual friend
    friend_edges = lines.flatMap(lambda line: create_friend_connection(*parse_line(line)))
    # save(friend_edges, "./result-network-problem-friends")
    
    # Select pairs of indirect friends then sum all the values to get their mutual friend count
    # mutual friend counts are of shapes ((user_id1, user_id2), count)
    mutual_friend_counts = friend_edges.groupByKey() \
        .filter(lambda edge: edge[1] != VALUE_DIRECT_FRIEND) \
        .map(lambda edge: (edge[0], sum(edge[1])))
    # save(mutual_friend_counts, "./result-network-problem-counts")

    # Create the recommendation objects, group them by key, then sort and truncate the recommendations to the 10 most highly recommended.
    # recommendations are of shapes (user_id, [recs...]) where recs is a length 0..10 array
    recommendations = mutual_friend_counts \
        .flatMap(lambda conn_count: mutual_friend_count_to_recommendation(*conn_count)) \
        .groupByKey() \
        .map(lambda edge: (edge[0], recommendation_to_sorted_truncated(edge[1])))

    save(recommendations, "./result")
    sc.stop()
    print('done')

spark_run()
