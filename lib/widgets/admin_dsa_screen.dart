import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminDsaScreen extends StatefulWidget {
  const AdminDsaScreen({super.key});

  @override
  State<AdminDsaScreen> createState() => _AdminDsaScreenState();
}

class _AdminDsaScreenState extends State<AdminDsaScreen> {
  // Input Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _approachController = TextEditingController();
  final TextEditingController _cppController = TextEditingController();
  final TextEditingController _javaController = TextEditingController();

  String selectedTopic = 'Arrays';
  String selectedDifficulty = 'Easy';
  bool isUploading = false;

  // Topics List
  final List<String> topics = [
    'Arrays',
    'Strings',
    'Linked List',
    'Searching & Sorting',
    'Binary Trees',
    'DP',
    'Graphs',
  ];

  // 🔥 ANTI-DUPLICATE LOGIC
  String _generateId(String title) {
    String cleanTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '');
    return cleanTitle.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }

  // 🔥 SAVE FUNCTION
  Future<void> _saveToFirestore(Map<String, dynamic> data) async {
    try {
      String docId = _generateId(data['title']);
      await FirebaseFirestore.instance
          .collection('dsa_questions')
          .doc(docId)
          .set({...data, 'timestamp': FieldValue.serverTimestamp()});
      debugPrint("✅ Saved: ${data['title']}");
    } catch (e) {
      debugPrint("❌ Error: $e");
    }
  }

  // 🚀 MANUAL UPLOAD
  Future<void> _uploadManual() async {
    if (_titleController.text.isEmpty) return;
    setState(() => isUploading = true);
    await _saveToFirestore({
      'title': _titleController.text,
      'topic': selectedTopic,
      'difficulty': selectedDifficulty,
      'problem': _problemController.text,
      'approach': _approachController.text,
      'cppCode': _cppController.text,
      'javaCode': _javaController.text,
    });
    setState(() => isUploading = false);
    _clearFields();
    Fluttertoast.showToast(msg: "Manual Question Uploaded!");
  }

  // ⚡⚡ BATCH 16: FAMOUS ALGORITHMS (Graph/Tree Legends) ⚡⚡
  Future<void> _uploadBatch16() async {
    setState(() => isUploading = true);

    List<Map<String, dynamic>> algoQuestions = [
      // ================= SHORTEST PATH ALGORITHMS =================
      {
        'title': "[GOOGLE] Dijkstra's Algorithm",
        'topic': "Graphs",
        'difficulty': "Medium",
        'problem':
            "Find the shortest path from a source node to all other nodes in a weighted graph (non-negative weights).",
        'approach':
            "Priority Queue (Min-Heap) use karo.\n1. `dist` array ko infinity set karo, source=0.\n2. Min-heap mein `{0, source}` daalo.\n3. Top nikalo, neighbours check karo. Agar `newDist < oldDist`, update karo aur heap mein daalo.",
        'cppCode':
            "vector<int> dijkstra(int V, vector<vector<int>> adj[], int S) {\n    priority_queue<pair<int,int>, vector<pair<int,int>>, greater<pair<int,int>>> pq;\n    vector<int> dist(V, 1e9);\n    dist[S] = 0; pq.push({0, S});\n    while(!pq.empty()){\n        int dis = pq.top().first; int node = pq.top().second; pq.pop();\n        for(auto it : adj[node]){\n            int edgeWeight = it[1], adjNode = it[0];\n            if(dis + edgeWeight < dist[adjNode]){\n                dist[adjNode] = dis + edgeWeight;\n                pq.push({dist[adjNode], adjNode});\n            }\n        }\n    }\n    return dist;\n}",
        'javaCode':
            "static int[] dijkstra(int V, ArrayList<ArrayList<ArrayList<Integer>>> adj, int S) {\n    PriorityQueue<Pair> pq = new PriorityQueue<>((x, y) -> x.distance - y.distance);\n    int[] dist = new int[V]; Arrays.fill(dist, (int)1e9);\n    dist[S] = 0; pq.add(new Pair(0, S));\n    while(pq.size() != 0) {\n        int dis = pq.peek().distance; int node = pq.peek().node; pq.remove();\n        for(int i = 0; i < adj.get(node).size(); i++) {\n            int edgeWeight = adj.get(node).get(i).get(1);\n            int adjNode = adj.get(node).get(i).get(0);\n            if(dis + edgeWeight < dist[adjNode]) {\n                dist[adjNode] = dis + edgeWeight;\n                pq.add(new Pair(dist[adjNode], adjNode));\n            }\n        }\n    }\n    return dist;\n}",
      },
      {
        'title': "[UBER] Bellman-Ford Algorithm",
        'topic': "Graphs",
        'difficulty': "Medium",
        'problem':
            "Find shortest paths from source to all vertices. Detect negative weight cycles.",
        'approach':
            "Relax Edges N-1 times.\n1. Saari edges par loop chalao N-1 baar.\n2. `if(dist[u] + wt < dist[v]) dist[v] = dist[u] + wt`.\n3. Ek baar aur check karo. Agar ab bhi value kam hoti hai, toh Negative Cycle hai.",
        'cppCode':
            "vector<int> bellman_ford(int V, vector<vector<int>>& edges, int S) {\n    vector<int> dist(V, 1e8); dist[S] = 0;\n    for (int i = 0; i < V - 1; i++) {\n        for (auto it : edges) {\n            int u = it[0], v = it[1], wt = it[2];\n            if (dist[u] != 1e8 && dist[u] + wt < dist[v]) dist[v] = dist[u] + wt;\n        }\n    }\n    // Check for negative cycle\n    for (auto it : edges) {\n        if (dist[it[0]] != 1e8 && dist[it[0]] + it[2] < dist[it[1]]) return {-1};\n    }\n    return dist;\n}",
        'javaCode':
            "public int[] bellman_ford(int V, ArrayList<ArrayList<Integer>> edges, int S) {\n    int[] dist = new int[V]; Arrays.fill(dist, (int)1e8); dist[S] = 0;\n    for (int i = 0; i < V - 1; i++) {\n        for (ArrayList<Integer> it : edges) {\n            int u = it.get(0), v = it.get(1), wt = it.get(2);\n            if (dist[u] != 1e8 && dist[u] + wt < dist[v]) dist[v] = dist[u] + wt;\n        }\n    }\n    return dist;\n}",
      },
      {
        'title': "[MICROSOFT] Floyd Warshall Algorithm",
        'topic': "Graphs",
        'difficulty': "Medium",
        'problem':
            "Find shortest distances between every pair of vertices (All-Pairs Shortest Path).",
        'approach':
            "3 Nested Loops.\nLogic: Kya hum `i` se `j` tak `k` ke through jaakar distance kam kar sakte hain?\n`matrix[i][j] = min(matrix[i][j], matrix[i][k] + matrix[k][j])`.",
        'cppCode':
            "void shortest_distance(vector<vector<int>>&matrix){\n    int n = matrix.size();\n    for(int k=0; k<n; k++){\n        for(int i=0; i<n; i++){\n            for(int j=0; j<n; j++){\n                if(matrix[i][k]==-1 || matrix[k][j]==-1) continue;\n                if(matrix[i][j]==-1) matrix[i][j] = matrix[i][k] + matrix[k][j];\n                else matrix[i][j] = min(matrix[i][j], matrix[i][k] + matrix[k][j]);\n            }\n        }\n    }\n}",
        'javaCode':
            "public void shortest_distance(int[][] matrix){\n    int n = matrix.length;\n    for(int k=0; k<n; k++){\n        for(int i=0; i<n; i++){\n            for(int j=0; j<n; j++){\n                if(matrix[i][k]==-1 || matrix[k][j]==-1) continue;\n                if(matrix[i][j]==-1) matrix[i][j] = matrix[i][k] + matrix[k][j];\n                else matrix[i][j] = Math.min(matrix[i][j], matrix[i][k] + matrix[k][j]);\n            }\n        }\n    }\n}",
      },

      // ================= MINIMUM SPANNING TREE (MST) =================
      {
        'title': "[SAMSUNG] Prim's Algorithm (MST)",
        'topic': "Graphs",
        'difficulty': "Medium",
        'problem':
            "Find the sum of weights of edges of the Minimum Spanning Tree.",
        'approach':
            "Greedy + Priority Queue.\nNode 0 se start karo. Uske connected edges ko PQ mein daalo. Minimum weight edge nikalo jo unvisited node par ja raha ho. Usse MST mein add karo.",
        'cppCode':
            "int spanningTree(int V, vector<vector<int>> adj[]) {\n    priority_queue<pair<int, int>, vector<pair<int, int>>, greater<pair<int, int>>> pq;\n    vector<int> vis(V, 0);\n    pq.push({0, 0});\n    int sum = 0;\n    while (!pq.empty()) {\n        auto it = pq.top(); pq.pop();\n        int wt = it.first, node = it.second;\n        if (vis[node]) continue;\n        vis[node] = 1; sum += wt;\n        for (auto it : adj[node]) {\n            if (!vis[it[0]]) pq.push({it[1], it[0]});\n        }\n    }\n    return sum;\n}",
        'javaCode':
            "// Use PriorityQueue storing {weight, node}.\n// Visited array to keep track.\n// Add minimum edge weight to sum if node not visited.",
      },
      {
        'title': "[FACEBOOK] Kruskal's Algorithm (MST)",
        'topic': "Graphs",
        'difficulty': "Medium",
        'problem': "Find MST using Kruskal's Algorithm (Edges sorting).",
        'approach':
            "Sort Edges + DSU.\n1. Saari edges ko weight ke hisaab se sort karo.\n2. Ek-ek karke edges uthao. Agar `find(u) != find(v)` (cycle nahi ban rahi), toh `union(u, v)` karo aur MST mein add karo.",
        'cppCode':
            "// Sort all edges by weight.\n// Iterate and use DSU DisjointSet ds(V);\n// if(ds.find(u) != ds.find(v)) { wt += edgeWt; ds.union(u, v); }",
        'javaCode':
            "// Sort edges.\n// Use DSU class.\n// If parents different, union them and add weight.",
      },

      // ================= ADVANCED TREE TRAVERSAL =================
      {
        'title': "[AMAZON] Morris Inorder Traversal",
        'topic': "Binary Trees",
        'difficulty': "Hard",
        'problem':
            "Inorder Traversal without Recursion and without Stack (O(1) Space).",
        'approach':
            "Threaded Binary Tree.\nAgar left child nahi hai -> print current, move right.\nAgar left hai -> rightmost node of left subtree dhoondo. Usko current se link karo (thread).",
        'cppCode':
            "vector<int> getInorder(TreeNode* root) {\n    vector<int> inorder;\n    TreeNode* cur = root;\n    while(cur != NULL) {\n        if(cur->left == NULL) {\n            inorder.push_back(cur->val); cur = cur->right;\n        } else {\n            TreeNode* prev = cur->left;\n            while(prev->right && prev->right != cur) prev = prev->right;\n            if(prev->right == NULL) { prev->right = cur; cur = cur->left; }\n            else { prev->right = NULL; inorder.push_back(cur->val); cur = cur->right; }\n        }\n    }\n    return inorder;\n}",
        'javaCode':
            "// Implement Morris Traversal logic.\n// Find predecessor, create link, move left.\n// If link exists, break link, print val, move right.",
      },
    ];

    for (var q in algoQuestions) {
      await _saveToFirestore(q);
      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // Rate limit handling
    }

    setState(() => isUploading = false);
    Fluttertoast.showToast(
      msg: "👑 BATCH 16 (FAMOUS ALGOS) Uploaded!",
      backgroundColor: Colors.deepPurple,
    );
  }

  void _clearFields() {
    _titleController.clear();
    _problemController.clear();
    _approachController.clear();
    _cppController.clear();
    _javaController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Content Panel"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🚀 BATCH UPLOAD BUTTON
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: Column(
                children: [
                  const Icon(Icons.hub, size: 50, color: Colors.deepPurple),
                  const SizedBox(height: 10),
                  const Text(
                    "Upload Batch 16",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Text(
                    "Famous Algorithms: Dijkstra, Bellman Ford, Floyd, Prim, Kruskal.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isUploading ? null : _uploadBatch16,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      icon: isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(
                        isUploading
                            ? "Uploading..."
                            : "UPLOAD BATCH 16 (Famous Algos)",
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 40, thickness: 2),
            const Text(
              "Manual Upload",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            DropdownButton<String>(
              value: selectedTopic,
              isExpanded: true,
              items: topics
                  .map(
                    (String value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (newValue) =>
                  setState(() => selectedTopic = newValue!),
            ),
            const SizedBox(height: 10),

            Row(
              children: ['Easy', 'Medium', 'Hard'].map((diff) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(diff),
                    selected: selectedDifficulty == diff,
                    onSelected: (selected) =>
                        setState(() => selectedDifficulty = diff),
                    selectedColor: Colors.amber,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            _buildTextField(_titleController, "Question Title"),
            _buildTextField(
              _problemController,
              "Problem Statement",
              maxLines: 3,
            ),
            _buildTextField(
              _approachController,
              "Logic (Hinglish Notes)",
              maxLines: 4,
            ),

            const SizedBox(height: 20),
            const Text(
              "💻 C++ Code:",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            _buildCodeField(_cppController),

            const SizedBox(height: 20),
            const Text(
              "☕ Java Code:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            _buildCodeField(_javaController),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isUploading ? null : _uploadManual,
                icon: const Icon(Icons.save),
                label: Text(isUploading ? "Saving..." : "SAVE SINGLE QUESTION"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildCodeField(TextEditingController ctrl) {
    return Container(
      color: Colors.grey[900],
      child: TextField(
        controller: ctrl,
        maxLines: 6,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontFamily: 'monospace',
        ),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(10),
          border: InputBorder.none,
          hintText: "// Paste code here...",
          hintStyle: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
