import Foundation

let json = """
{
    "query": "INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);"
}
"""

let url = URL(string: "https://bdgwzkpteyxhlgprlmye.supabase.co/rest/v1/")!
var request = URLRequest(url: url)
// We don't have direct access to sql endpoint usually via rest/v1, usually the endpoint is rest/v1/rpc or you use another method. 
