import Foundation
import Supabase

// This is a scratch script to debug offer fetching
// We will use the existing SupabaseManager to fetch data

@MainActor
func debugOffers() async {
    print("--- DEBUG OFFERS ---")
    do {
        let client = SupabaseManager.shared.client
        let response: PostgrestResponse<[OfferDTO]> = try await client
            .from("offers")
            .select()
            .execute()
        
        let offers = response.value
        print("Total offers in DB: \(offers.count)")
        for offer in offers {
            print("Name: \(offer.name), Status: \(offer.status), EndDate: \(offer.end_date ?? "nil")")
        }
    } catch {
        print("Error fetching offers: \(error)")
    }
}
