class ApiService {
  // Example skeleton for an API service
  
  Future<String> fetchData() async {
    // Simulate network latency
    await Future.delayed(const Duration(seconds: 1));
    return 'Data from API';
  }
}
