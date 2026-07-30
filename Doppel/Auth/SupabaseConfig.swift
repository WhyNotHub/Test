import Foundation
import Supabase

/// Fill these in from your Supabase project's Settings -> API page before
/// building. The anon/publishable key is safe to ship inside the app -- it's
/// a public, rate-limited key. Access to actual rows is enforced by the Row
/// Level Security policies on each table (see the SQL in the setup guide),
/// not by keeping this key secret. Never put the `service_role` key here or
/// anywhere else in the app -- that one bypasses Row Level Security entirely.
enum SupabaseConfig {
    static let url = URL(string: "https://YOUR-PROJECT-REF.supabase.co")!
    static let anonKey = "YOUR-ANON-OR-PUBLISHABLE-KEY"
}

let supabase = SupabaseClient(supabaseURL: SupabaseConfig.url, supabaseKey: SupabaseConfig.anonKey)
