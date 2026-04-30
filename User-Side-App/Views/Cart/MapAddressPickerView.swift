//  MapAddressPickerView.swift
//  User-Side-App
//  Interactive MapKit view for precise delivery location selection
//  Includes Real-Time Address Search and Structured Field Extraction

import SwiftUI
import MapKit
import CoreLocation
import Combine

struct StructuredAddress {
    var buildingName: String = ""
    var areaStreet: String = ""
    var landmark: String = ""
    var city: String = ""
    var state: String = ""
    var pincode: String = ""
    var country: String = "India"

    var fullAddress: String {
        let parts = [buildingName, areaStreet, landmark, city, state, pincode]
            .filter { !$0.isEmpty }
        return parts.joined(separator: ", ")
    }
}

struct MapAddressPickerView: View {
    let onSave: (StructuredAddress) -> Void
    @Environment(\.dismiss) private var dismiss

    // CoreLocation Geocoder
    private let geocoder = CLGeocoder()

    // Default coordinates (e.g., Mumbai)
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

    @State private var centerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777)

    // Search State
    @StateObject private var searchManager = AddressSearchManager()
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool

    // UI State
    @State private var isDragging: Bool = false
    @State private var isLocating: Bool = false
    @State private var currentAddress = StructuredAddress()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ZStack(alignment: .bottom) {
                    // MARK: - Map
                    Map(position: $position, interactionModes: .all) {
                        // Center pin overlay
                    }
                    .onMapCameraChange(frequency: .continuous) { context in
                        isDragging = true
                        centerCoordinate = context.region.center
                    }
                    .onMapCameraChange(frequency: .onEnd) { context in
                        isDragging = false
                        centerCoordinate = context.region.center
                        reverseGeocode(coordinate: centerCoordinate)
                    }
                    .ignoresSafeArea()

                    // MARK: - Center Pin
                    VStack(spacing: 0) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(AppColors.gold)
                            .background(Circle().fill(.white))
                            .offset(y: isDragging ? -15 : 0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isDragging)

                        Ellipse()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 14, height: 4)
                            .scaleEffect(isDragging ? 0.5 : 1)
                            .opacity(isDragging ? 0.3 : 1)
                            .animation(.spring(response: 0.3), value: isDragging)
                    }
                    .padding(.bottom, 36)

                    // MARK: - Bottom Sheet Card
                    VStack(spacing: 16) {
                        // Preview
                        HStack(spacing: 16) {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .foregroundStyle(AppColors.gold)
                                .rotationEffect(.degrees(isLocating ? 360 : 0))
                                .animation(isLocating ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isLocating)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Delivery Landmark").font(.caption).fontWeight(.bold).tracking(2).foregroundStyle(AppColors.grayLight)
                                Text(currentAddress.fullAddress.isEmpty ? "Locating..." : currentAddress.fullAddress)
                                    .font(.subheadline)
                                    .foregroundStyle(AppColors.pureWhite)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                            }
                            Spacer()
                        }

                        // Structured Inputs
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                customField(label: "BLDG / SUITE", text: $currentAddress.buildingName)
                                customField(label: "PINCODE", text: $currentAddress.pincode)
                            }

                            customField(label: "LANDMARK (OPTIONAL)", text: $currentAddress.landmark)
                        }

                        Button(action: {
                            if !currentAddress.city.isEmpty {
                                onSave(currentAddress)
                            }
                        }) {
                            Text("SAVE FULL ADDRESS")
                                .font(.subheadline).fontWeight(.bold).tracking(2)
                                .foregroundStyle(AppColors.background)
                                .frame(maxWidth: .infinity).padding(.vertical, 18)
                                .background(LinearGradient.goldSubtle.opacity(currentAddress.city.isEmpty ? 0.4 : 1.0))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(PressButtonStyle())
                        .disabled(currentAddress.city.isEmpty)
                    }
                    .padding(24)
                    .background(AppColors.surfaceDark.shadow(color: .black.opacity(0.4), radius: 20, y: -10))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .ignoresSafeArea(edges: .bottom)
                    .offset(y: isSearchFocused ? 300 : 0)
                    .animation(.spring(), value: isSearchFocused)
                }

                // MARK: - Search Bar & Results Overlay
                addressSearchBar
            }
            .navigationTitle("SELECT LOCATION")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left").foregroundStyle(AppColors.gold)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .onAppear {
            reverseGeocode(coordinate: centerCoordinate)
        }
    }

    private func customField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 8, weight: .bold)).tracking(1).foregroundStyle(AppColors.grayLight)
            TextField("", text: text)
                .padding(12)
                .background(AppColors.background)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1))
                .foregroundStyle(AppColors.pureWhite)
                .font(.subheadline)
        }
    }

    private var addressSearchBar: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(AppColors.gold)
                TextField("Search area or building...", text: $searchText)
                    .foregroundStyle(AppColors.pureWhite)
                    .focused($isSearchFocused)
                    .onChange(of: searchText) { _, newValue in
                        searchManager.searchQuery = newValue
                    }

                if !searchText.isEmpty {
                    Button(action: { searchText = ""; searchManager.results = [] }) {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(AppColors.grayLight)
                    }
                }
            }
            .padding(16)
            .background(AppColors.surfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSearchFocused ? AppColors.gold : AppColors.grayDark.opacity(0.3), lineWidth: 1))
            .padding(16)

            if isSearchFocused && !searchManager.results.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(searchManager.results, id: \.self) { result in
                            Button(action: { selectSearchResult(result) }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(result.title).font(.subheadline).fontWeight(.medium).foregroundStyle(AppColors.pureWhite)
                                    Text(result.subtitle).font(.caption).foregroundStyle(AppColors.grayLight)
                                    Divider().background(AppColors.grayDark.opacity(0.2)).padding(.top, 8)
                                }
                                .padding(.horizontal, 16).padding(.vertical, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .background(AppColors.surfaceDark)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                    .frame(maxHeight: 200)
                }
            }
        }
    }

    // MARK: - Logic

    private func selectSearchResult(_ result: MKLocalSearchCompletion) {
        isSearchFocused = false
        searchText = result.title

        let searchRequest = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: searchRequest)

        search.start { response, error in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }

            withAnimation(.spring()) {
                self.position = .region(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                ))
                self.centerCoordinate = coordinate
            }
            reverseGeocode(coordinate: coordinate)
        }
    }

    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        isLocating = true
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "en_US")) { placemarks, error in
            isLocating = false
            guard let placemark = placemarks?.first else { return }

            withAnimation {
                self.currentAddress.buildingName = placemark.name ?? ""
                self.currentAddress.areaStreet = [placemark.subLocality, placemark.thoroughfare].compactMap { $0 }.joined(separator: ", ")
                self.currentAddress.city = placemark.locality ?? ""
                self.currentAddress.state = placemark.administrativeArea ?? ""
                self.currentAddress.pincode = placemark.postalCode ?? ""
                self.currentAddress.country = placemark.country ?? "India"
            }
        }
    }
}

// MARK: - Search Manager (MKLocalSearchCompleter remains same)
class AddressSearchManager: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchQuery = ""
    @Published var results: [MKLocalSearchCompletion] = []
    private var completer = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
        $searchQuery.debounce(for: .milliseconds(300), scheduler: RunLoop.main).sink { [weak self] query in
            self?.completer.queryFragment = query
        }.store(in: &cancellables)
    }
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) { self.results = completer.results }
}

#Preview {
    MapAddressPickerView(onSave: { _ in })
        .withLuxePreviewEnvironment()
}
