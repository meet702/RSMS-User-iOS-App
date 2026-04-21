import Foundation

let json = """
{
    "id": "81266347-e4ac-40c6-82d4-4eba96428458",
    "first_name": "Krishna",
    "last_name": "Upadhyay",
    "email": "krishna.27.5.2005@gmail.com",
    "tier": "SILVER",
    "loyalty_points": 0
}
"""

let url = URL(string: "https://bdgwzkpteyxhlgprlmye.supabase.co/rest/v1/customer_profiles")!
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.addValue("application/json", forHTTPHeaderField: "Content-Type")
request.addValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJkZ3d6a3B0ZXl4aGxncHJsbXllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYxNTM5OTksImV4cCI6MjA5MTcyOTk5OX0.AU2fdMOK0WfjqQEFqLsMfGCWChf3rMzSdVOzQ_5QYOU", forHTTPHeaderField: "apikey")
request.addValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJkZ3d6a3B0ZXl4aGxncHJsbXllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYxNTM5OTksImV4cCI6MjA5MTcyOTk5OX0.AU2fdMOK0WfjqQEFqLsMfGCWChf3rMzSdVOzQ_5QYOU", forHTTPHeaderField: "Authorization")
request.httpBody = json.data(using: .utf8)

let semaphore = DispatchSemaphore(value: 0)

let task = URLSession.shared.dataTask(with: request) { data, response, error in
    if let data = data, let str = String(data: data, encoding: .utf8) {
        print("Insert profile result: \(str)")
    }
    semaphore.signal()
}
task.resume()
semaphore.wait()
