class ClusterData {
  final String clusterName;
  final int leads;
  final int won;
  final int lost;
  final int ongoing;

  ClusterData({
    required this.clusterName,
    required this.leads,
    required this.won,
    required this.lost,
    required this.ongoing,
  });
}

class LeadsWonData {
  final String clusterName; // Example: "WK-1", "WK-2", etc.
  final int won; // Number of leads won for that week

  LeadsWonData({required this.clusterName, required this.won});
}

class RevenueData {
  final String clusterName; // e.g., "Cluster 1"
  final int target; // target revenue
  final int achieved; // achieved revenue

  RevenueData({
    required this.clusterName,
    required this.target,
    required this.achieved,
  });
}
