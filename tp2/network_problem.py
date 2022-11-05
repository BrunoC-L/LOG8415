#inspired from : https://github.com/JaceyPenny/pyspark-friend-recommendation

from pyspark import SparkConf, SparkContext
from os import remove, removedirs, listdir

VALUE_DIRECT_FRIEND = 0
VALUE_COMMON_FRIEND = 1


def parse_line(line):
    """
    This function take a line from the input text file and transform it to an usable tuple.
    Example of line input : '0\t1,2,3,4,5\n'

    args : 
        line type:string like <ID>TAB<friend1>,<friend2>,<friend3>...

    output a tuple type (int,List[int]) 
    where the first element is an id and the second element is a list of id of user's friends
    output example :  (0,[1,2,3,4,5])
    """
    
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


def create_friend_connection(user, friends):
    """
    This function create connection between user and all friend, and between all his friend and specify if there are friend or not with 0 or 1 flag
   
    args: 
        user : type int, id of the user
        friends : type List(int), list of id
        
    output: list of tuple (key,value) with key as a tuple of id and value as 0 or 1
        Example: [((0,1),0), ((0,2),1), ....] --> users 0 and 1 are friends and users 0 and 2 have a mutual friend
    """
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


def mutual_friend_count_to_recommendation(edge, count):
    """
     This function create recommandation given a connection 'edge' and the count of mutual friend 'count'
   
    args: 
        edge : (int, int) tuple of user id, (user0, user1)
        count : int number of mutual friend
        
    output: list of recommandation (2) for given connection including the count of mutual friends
            list of tuple (key,value) with key as an id (int) and value as a tuple (int, int)
            Example : [(user0, (user1, count)), (user1, (user0, count))]
    """
    user_0 = edge[0]
    user_1 = edge[1]
    return [(user_0, (user_1, count)), (user_1, (user_0, count))]

def aBetterThanB(recommendationA, recommendationB):
    """
    This function returns True or False depending of the two user_id in recommandation
    
    args: 
        recommendationA
        recommendationB
    
    output: 
        Boolean
    """
    
    # prefer larger friend counter ([1]) but if equal smaller user_id ([0])
    return recommendationA[1] > recommendationB[1] or (recommendationA[1] == recommendationB[1] and recommendationA[0] < recommendationB[0])


def insert(recommendations, recommendation):
    """
    This function select the top 10 recommandations based of number of mutual friends. to a list for a specific user.
    
    args: 
        recommendations : list of recommendations
        recommendation : one recommendation
    output: 
        None (it modify the input 'recommendations')
    """
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
    """
    This function sort recommendations from best to worst based on the number of mutual friends
    
    args: 
        recommendations : tuple (int, list[tuple(int,int)]), first element is an user id and second element is a list of recommendations for the user
    output: 
        list(int), list of user id recommanded
    """
    
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

    conf = SparkConf().set("spark.executor.cores", 4).set("spark.executor.instances", 4)
    sc = SparkContext(conf=conf)

    fileLoc = 'soc-LiveJournal1Adj.txt'
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

    save(recommendations, "/socialResult")
    sc.stop()
    print('done')

spark_run()
