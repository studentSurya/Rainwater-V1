import SwiftUI
import Charts
import CoreLocation

struct MenuPage: View {
    
    @EnvironmentObject var locationManager: LocationManager
    
    // User inputs
    @State private var area: String = ""
    @State private var floors: String = ""
    @State private var length: String = ""
    @State private var width: String = ""
    @State private var answer: String = "0.00"
    @State private var forecastAnswer: String = "0.00"
    @State private var forecastRainfall: Double = 0.0
    @State private var averageAnnualRainfall: Double = 0.0
    @State private var roofArea: Double = 0.0
    @State private var isImperial: Bool = true
    @State private var useMyLocation: Bool = false
    @State private var long: String = ""
    @State private var lat: String = ""
    @State private var codeData: LocationRainfallData?
    @State private var selectedCalculationType: Int = -1
    @State private var rain_data: RainWaterCollectionData?
    @State private var historicalRainData: LocationRainfallData?
    @State private var waterTankSize: Double = 1200.0
    
    // Other variables
    let harvestEfficiency: Double = 0.75  //NOTE: We assume an 75% efficient system.
    
    let topics = [
        "Benefits of Rainwater Harvesting",
        "Types of Rainwater Harvesting Systems",
        "Rainwater Filtration Methods",
        "Storage Solutions for Rainwater",
        "Legal Considerations"
    ]
    var body: some View {
        TabView {
            // Home Tab
            //Spacer()
            ZStack {
                // Background Gradient
                Image("rain").resizable().edgesIgnoringSafeArea(.top)
//                Color(.blue).edgesIgnoringSafeArea(.top)

                VStack {
                    // App Title
                    Text("Rain Bounty")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .shadow(
                            color: Color.primary.opacity(1.0), /// shadow color
                            radius: 10, /// shadow radius
                            x: 0, /// x offset
                            y: 4 /// y offset
                        )
                        .padding()
                        .background(Color.black.opacity(0))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding(.horizontal)
                    // Welcome Message
                    VStack(alignment: .center) {
                        Text("""
    Harvest the rains
    Reap the gains!
""")
                            .foregroundColor(.white)
                            .font(.title2)
                            .fontWeight(.bold)
                            .shadow(
                                color: Color.primary.opacity(1.0), /// shadow color
                                radius: 10, /// shadow radius
                                x: 0, /// x offset
                                y: 4 /// y offset
                            )
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.black.opacity(0))
                            .cornerRadius(15)
                            .shadow(radius: 10)
                            .padding(.horizontal)

                        //Spacer()
                        Image("applogo")
                            .resizable()
                            .frame(width: 256, height: 256)
                            .scaledToFit()
                            .padding()
                            .background(Color.black.opacity(0))
                            .cornerRadius(15)
                            .shadow(radius: 10)
                            .padding(.horizontal)
                        
                        Text("Rainwater harvesting is a simple and sustainable technique that captures, diverts, and stores rainwater for later use like irrigation, washing driveways and vehicles, filling your swimming pool, flushing toilets etc. in your household.")
                            .foregroundColor(.white)
                            .font(.body)
                            .fontWeight(.semibold)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .multilineTextAlignment(.leading)
                            .cornerRadius(15)
                            .shadow(radius: 10)

                    }
                    .padding()
                    .background(Color.white.opacity(0.0))
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .padding(.horizontal)
                    
                    // Placeholder for illustrative image (ensure you have this image in your assets)
//                    Image("rain") // Use your own image asset
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 200)
//                        .cornerRadius(15)
//                        .shadow(radius: 5)
//                        .padding()

                    // Image Collage
//                    Image(systemName: "cloud.rain.fill")
//                        .frame(width: 200, height: 200)
//                        .padding(.horizontal)
                }
                .padding()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }

            //************* Chart View !! ****************
            ZStack {
                VStack {
                    VStack {
                        //Slider(value: $waterTankSize, in: 0...3000)
                        Slider(
                            value: Binding(get: {
                                self.waterTankSize
                            }, set: { (newVal) in
                                self.waterTankSize = newVal
                                self.waterTankSliderChanged()
                            }),
                            in: 0...3000,
                            step: 50
                        ) {
                            Text("Tank size (gal)")
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("3000")
                        }
                        
                        Text("Tank Size (gal) \(waterTankSize, specifier: "%.1f")")
                    }
                    // Background Gradient
                    if (rain_data != nil)
                    {
                        Chart {
                            let calendar = Calendar.autoupdatingCurrent
                            
                            //Tank water size Chart
                            ForEach(rain_data!.weeklyRainCollectionData) { dataPoint in
                                LineMark(
                                    x: .value("Week", calendar.date(from:DateComponents( weekOfYear: dataPoint.weekNumber, yearForWeekOfYear: 2024))!, unit: .weekOfYear),
                                    y: .value("Tank water", dataPoint.tankWater)
                                )
                                .foregroundStyle(.blue)
                            }
                            
                            // Rainfall Chart
                            // Old code for reference:                                 x: .value("Week", dataPoint.weekNumber!, unit: .weekOfYear), //x: .value("Week", calendar.date(from:DateComponents(year: 2021, weekOfYear: dataPoint.weekNumber))!),
                            
                            ForEach(rain_data!.weeklyRainCollectionData) { dataPoint in
                                BarMark(
                                    x: .value("Week", calendar.date(from:DateComponents( weekOfYear: dataPoint.weekNumber, yearForWeekOfYear: 2024))!, unit: .weekOfYear),
                                    y: .value("Rain Collection", dataPoint.rainCollection)
                                )
                                .foregroundStyle(dataPoint.rainFall > 100 ? .green : .red)
                                //.chartYAxis(axis: .hidden) // Hide the volume y-axis
                            }
                            
                        }
                        
                        .chartXAxis {
                            //    AxisMarks { _ in
                            //        AxisValueLabel()
                            //    }
                            AxisMarks(values: .stride(by: .month, count: 2)) { value in
                                if let date = value.as(Date.self) {
                                    let month = Calendar.current.component(.month, from: date)
                                    switch month {
                                    default:
                                        AxisValueLabel(format: .dateTime.month())
                                    }
                                }
                                AxisGridLine()
                                AxisTick()
                            }
                        }
                        .chartYAxis {
                            //AxisMarks { _ in
                            //   AxisValueLabel()
                            //}
                            AxisMarks(values: .automatic(desiredCount: 5))
                        }
                        .padding()
                    }
                }
            }
            .tabItem {
                Image(systemName: "star.fill")
                Text("Star")
            }

            //Spacer()
            RW101Content
                .tabItem {
                    Image(systemName: "pencil")
                    Text("Harvesting 101")
                }
            //Spacer()
            ZStack {
//                Color(.blue).edgesIgnoringSafeArea(.top)
                Image("rain").resizable().edgesIgnoringSafeArea(.top)
                        VStack(spacing: 10) {
                            Text("Rain water calculator")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .shadow(
                                    color: Color.primary.opacity(0.2), /// shadow color
                                    radius: 2, /// shadow radius
                                    x: 0, /// x offset
                                    y: 2 /// y offset
                                )
                            
                            // Segmented Control for Choosing Calculation Type
                            Picker(selection: $selectedCalculationType, label: Text("Calculation Type")) {
                                // Initial state explaining the function
                                Text("User Guide").tag(-1)
                                Text("Length x Width").tag(0)
                                Text("Area / Floors").tag(1)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            
                            // Display explanation when no calculation type is selected
                            if selectedCalculationType == -1 {
                                VStack {
                                    Text("Overview")
                                        .bold()
                                        .font(.title2)
                                        .padding()
                                    Text("Our Rain Water Calculator can help you understand the rain water collection potential you have for your area using your Longitude and Latitude or Locations Settings. You will also be informed about the upcoming 14-days rainwater collection opportunity for planning rain water usage once you have the setup. Furthermore, we will notify you if you need to have your tanks empty or not.")
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white.opacity(0.4))
                                .cornerRadius(15)
                                .shadow(radius: 10)
                            }
                            
                            // If user selects Length by Width option
                            else if selectedCalculationType == 0 {
                                VStack(spacing: 5) {
                                    Toggle("Imperial Units", isOn: $isImperial)
                                        .padding()
                                        .background(Color.white.opacity(0.9))
                                        .cornerRadius(10)
                                    
                                    Toggle("Use My Location", isOn: $useMyLocation)
                                        .padding()
                                        .background(Color.white.opacity(0.9))
                                        .cornerRadius(10)
                                        .onChange(of: useMyLocation) {
                                            if (useMyLocation) {
                                                long = "\(String(describing: locationManager.location!.coordinate.longitude))"
                                                lat = "\(String(describing: locationManager.location!.coordinate.latitude))"
                                            }
                                        }
                                    
                                    // Longitude and Latitude input fields
                                    inputField(label: "Latitude", text: $lat)
                                        .disabled(useMyLocation)
                                    inputField(label: "Longitude", text: $long )
                                        .disabled(useMyLocation)
                                    
                                    // Length and Width fields
                                    var unit: String = isImperial ? "ft" : "m"
                                    inputField(label: "Length (\(unit))", text: $length)
                                    inputField(label: "Width (\(unit))", text: $width)
                                    /*
                                     if isImperial {
                                     //lengthWidthInputFields(unit: "ft")
                                     } else {
                                     //lengthWidthInputFields(unit: "m")
                                     }
                                     */
                                    
                                    // Calculate Button
                                    calculateButton {
                                        guard let lengthValue = Double(length),
                                              let widthValue = Double(width) else {
                                            answer = "Invalid Input"
                                            return
                                        }
                                        roofArea = lengthValue * widthValue
                                        calculateRainCollection(roofArea: roofArea)
                                    }
                                    
                                    // Display Results
                                    resultCard(
                                        title: "Roof Area " + (isImperial ? "(sq-ft)" : "(sq-meter)"),
                                        value: String(format: "%.2f", roofArea)
                                    )
                                    .lineLimit(nil) // Allows text to wrap to multiple lines
                                    .frame(maxWidth: .infinity, alignment: .leading) // Prevent truncation, full width allowed
                                    
                                    resultCard(
                                        title: "Average annual rainfall " + (isImperial ? "(in)" : "(mm)"),
                                        value: String(format: "%.2f", averageAnnualRainfall)
                                    )
                                    .lineLimit(nil)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    resultCard(
                                        title: "Annual Rain Collection " + (isImperial ? "(Gallons)" : "(Liters)"),
                                        value: "\(answer)"
                                    )
                                    .lineLimit(nil)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    resultCard(
                                        title: "14d forecast Rain Collection " + (isImperial ? "(Gallons)" : "(Liters)"),
                                        value: "\(forecastAnswer)"
                                    )
                                    .lineLimit(nil)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    
                                    if (Double(forecastAnswer)! > 150)
                                    {
                                        Text("Incoming Rain. Empty out your tanks!!! ")
                                            .lineLimit(nil)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.blue)
                                            .font(.headline)
                                    }
                                    
                                
                                }
                                .padding()
                                .background(Color.white.opacity(0.4))
                                .cornerRadius(15)
                                .shadow(radius: 10)
                            }
                            
                            // If user selects Area by Floors option
                            else if selectedCalculationType == 1 {
                                VStack(spacing: 5) {
                                    Toggle("Imperial Units", isOn: $isImperial)
                                        .padding()
                                        .background(Color.white.opacity(0.9))
                                        .cornerRadius(10)
                                    
                                    Toggle("Use My Location", isOn: $useMyLocation)
                                        .padding()
                                        .background(Color.white.opacity(0.9))
                                        .cornerRadius(10)
                                        .onChange(of: useMyLocation) {
                                            if (useMyLocation) {
                                                long = "\(String(describing: locationManager.location!.coordinate.longitude))"
                                                lat = "\(String(describing: locationManager.location!.coordinate.latitude))"
                                            }
                                        }
                                    
                                    // Longitude and Latitude input fields
                                    inputField(label: "Latitude", text: $lat)
                                        .disabled(useMyLocation)
                                    inputField(label: "Longitude", text: $long )
                                        .disabled(useMyLocation)
                                    
                                    // Area and Floors fields
                                    var unit: String = isImperial ? "sqft" : "sqm"
                                    inputField(label: "Area (\(unit))", text: $area)
                                    inputField(label: "Floors", text: $floors)
                                    /*
                                    if isImperial {
                                        areaFloorsInputFields(unit: "sqft")
                                    } else {
                                        areaFloorsInputFields(unit: "sqm")
                                    }*/
                                    
                                    // Calculate Button
                                    calculateButton {
                                        guard let areaValue = Double(area),
                                              let floorsValue = Double(floors) else {
                                            answer = "Invalid Input"
                                            return
                                        }
                                        roofArea = areaValue / floorsValue
                                        calculateRainCollection(roofArea: roofArea)
                                    }
                                    
                                    // Display Results
                                        resultCard(
                                            title: "Roof Area " + (isImperial ? "(sq-ft)" : "(sq-meter)"),
                                            value: String(format: "%.2f", roofArea)
                                        )
            
                                        resultCard(
                                            title: "Average annual rainfall " + (isImperial ? "(in)" : "(mm)"),
                                            value: String(format: "%.2f", averageAnnualRainfall)
                                        )
                                    
                                        resultCard(
                                            title: "Annual Rain Collection " + (isImperial ? "(Gallons)" : "(Liters)"),
                                            value: "\(answer)"
                                        )
                                    
                                        resultCard(
                                            title: "14d forecast Rain Collection " + (isImperial ? "(Gallons)" : "(Liters)"),
                                            value: "\(forecastAnswer)"
                                        )
                                    
                                    if (Double(forecastAnswer)! > 150)
                                    {
                                        Text("Incoming Rain. Empty out your tanks!!! ")
                                            .lineLimit(nil)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.blue)
                                            .font(.headline)
                                    }

                                }
                                .padding()
                                .background(Color.white.opacity(0.4))
                                .cornerRadius(15)
                                .shadow(radius: 10)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.85))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                    }
                    .tabItem {
                        Image(systemName: "pencil.and.ruler.fill")
                        Text("Rain water calculator")
                    }
            //Spacer()
//            rainwaterHarvestingView
//                .tabItem { 
//                    Image(systemName: "arrow.right")
//                    Text("Get Started")
//                }
            //Spacer()
            resourcesTab
                .tabItem {
                    Image(systemName: "list.bullet").foregroundColor(.mint)
                    Text("Resources")
                }
            //Spacer()
        }
        .accentColor(.blue)
    }
    struct RainwaterHarvestingView: View {
        var body: some View {
            ZStack(){
//                Color(.blue).edgesIgnoringSafeArea(.top)
                Image("rain").resizable().edgesIgnoringSafeArea(.top)
                VStack {
                    Text("Rainwater Collection")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)

                    // Description text above the list
                    Text("A simple residential harvesting system comprises of the following components. The main purpose of the collected water would be for outdoor uses that do not require potable water.")
                        .font(.system(size: 16, weight: .medium))
                        .padding()
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.blue) // Blue text for the theme
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        //.padding(.horizontal)
                    
                    // List of components with blue bullet styling
                    List {
                        Text("Catchment surface - the collection surface from which rainfall runs off like your roof")
                            .listRowBackground(Color.white)
                        Text("Gutters and downspouts – to channel water from the roof to the tank")
                            .listRowBackground(Color.white)
                        Text("Screens, first-flush diverters, and roof washers - components which remove debris and dust from the captured rainwater before it goes to the tank")
                            .listRowBackground(Color.white)
                        Text("Storage system – to store the collected rain water.")
                            .listRowBackground(Color.white)
                        Text("Delivery system: gravity-fed or pumped to the end use like watering your lawn and plants")
                            .listRowBackground(Color.white)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.white) // Ensure the list background stays white
                    
                    Spacer()
                    
                    // Image placeholder for the system diagram
                    Image("rainwater-harvesting-system")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures the image occupies majority of space below
                        .background(Color.white) // White background for the image section
                } //VStack
                .padding()
                .background(Color.white.opacity(0.3)) // Light blueish white background for overall theme
            } //ZStack
        } //View
    } //View

    // Reusable View Variable
    let rainwaterHarvestingView = RainwaterHarvestingView()
    
    private let RW101Content: some View = ZStack() {
        Image("rain").resizable().edgesIgnoringSafeArea(.top)
        VStack(alignment: .center, spacing: 16) {
            Text("Harvesting 101")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .shadow(
                    color: Color.primary.opacity(0.2), /// shadow color
                    radius: 2, /// shadow radius
                    x: 0, /// x offset
                    y: 2 /// y offset
                )
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    Section(header: HStack {
                        Image(systemName: "questionmark.circle")
                        Text("What does a typical rain water harvesting system look like?")
                            .font(.title2)
                        .foregroundColor(.black) }) {
                            // Image placeholder for the system diagram
                            Image("rainwater-harvesting-system")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures the image occupies majority of space below
                                .background(Color.white) // White background for the image section

                            Text("""
    The main purpose of the water collected using a Rain water harvesting system would be for outdoor uses that do not require potable water. A simple residential harvesting system comprises of the following components. 
    
    • **Catchment surface** - the collection surface from which rainfall runs off like your roof.
    • **Gutters and downspouts** – to channel water from the roof to the tank.
    • **Screens, first-flush diverters, and roof washers** - components which remove debris and dust from the captured rainwater before it goes to the tank.
    • **Storage system** – to store the collected rain water.
    • **Delivery system** - gravity-fed or pumped to the end use like watering your lawn and plants.
    
    """)
                            .font(.body)
                            .foregroundColor(.black)
                        } //Section
                        .padding()

                    Section(header: HStack {
                        Image(systemName: "questionmark.circle")
                        Text("Is it illegal to harvest rainwater?")
                            .font(.title2)
                        .foregroundColor(.black)}) {
                            Text("""
    In the majority of cases, the answer is no and is actively encouraged by state governments and individual counties with rebates on equipment setup and tax incentives. So, if you are thinking about a rainwater harvesting solution, it is always best to check with your local authorities to ensure your system complies with local codes/regulations as well as learn about the rebates and tax incentives.
    
    """)
                            .font(.body)
                            .foregroundColor(.black)
                        } //Section
                        .padding()
                    
                    Section(header: HStack {
                        Image(systemName: "questionmark.circle")
                        Text("What are the benefits of Rainwater Collection?")
                            .font(.title2)
                        .foregroundColor(.black)}) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Protects the environment")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Text("""
    • Rainwater harvesting conserves water, one of the most precious natural resources.
    • By using the harvested water, you reduce the carbon footprint associated with manufacturing and transporting municipal water to your location instead.
    • It can also reduce the amount of stormwater runoff that can cause flooding and erosion.
    • Rainwater is great for watering lawns and gardens as it is free of chemicals and salts that are typical of any treated water. Additionally, rainwater has a balanced pH that is required by the plants.
    
    """)
                                .font(.body)
                                .foregroundColor(.black)
                                
                                Text("Saves Money")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Text("""
    • Rainwater harvesting can reduce the amount of water you need to buy from the municipality, which can lower your water bill.
    
    """)
                                    .font(.body)
                                    .foregroundColor(.black)
                                
                                Text("Provides an alternative source of water")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Text("""
    • Rainwater can be used for irrigation, washing driveways/vehicles, flushing toilets, etc.
    • If a municipality can't provide water, people with rainwater harvesting systems may have a reliable water source.
    
    """)
                                .font(.body)
                                .foregroundColor(.black)
                            }
                        } //Section
                        .padding()
                    
                    Section(header: HStack {
                        Image(systemName: "questionmark.circle")
                        Text("How much rainwater can I collect?")
                            .font(.title2)
                        .foregroundColor(.black)}) {
                            Text("""
    You need to know your average annual rainfall data for your area and approximate collection surface area, like your roof, using either the length and width of your house or square footage. 
    
    Don't fret! To simplify this calculation, you can use our **Rain Water Calculator!!**.
    """)
                            .font(.body)
                            .foregroundColor(.black)
                        }
                        .padding()
                } // VStack
                .padding()
                .background(Color.white.opacity(0.85))
            } //ScrollView
        } // Outer VStack
    } //ZStack
    // MARK: - Resource Data Structure
    struct Resource {
        let description: String
        let url: String
    }

    // Example placeholder URLs for resources
    let resources: [Resource] = [
        Resource(description: "Introduction to Rainwater Harvesting", url: "https://en.wikipedia.org/wiki/Rainwater_harvesting#:~:text=Rainwater%20harvesting%20(RWH)%20is%20the,and%20restores%20the%20ground%20water."),
        Resource(description: "Rainwater Harvesting Guidelines", url: "https://www.epa.gov/sites/default/files/2015-10/documents/gi_munichandbook_harvesting.pdf"),
        Resource(description: "Rainwater System Maintenance Tips", url: "https://harvestrain.com/maintenance-of-a-rainwater-harvesting-system/"),
        Resource(description: "Rainwater Quality Testing", url: "https://mytapscore.com/collections/rainwater-harvesting-water-test-kits?srsltid=AfmBOorSGBTkMZnQcQc_QEaMVFjqAm5ulP9_Hf0ksvLvZhFeu42DRLw5"),
        Resource(description: "Innovative Rainwater Solutions", url: "https://smartwateronline.com/news/revolutionising-urban-spaces-5-innovative-rainwater-harvesting-techniques?srsltid=AfmBOooMi4jmERVY7bFEC8dlxn2MaBD7FK0k1TjvfvWuUEFfkrgm1mz2")
    ]

    // MARK: - Resources Tab
    private var resourcesTab: some View {
        ZStack(){
            Image("rain").resizable().edgesIgnoringSafeArea(.top)
            VStack(alignment: .center, spacing: 16) {
                Text("Resources")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .shadow(
                        color: Color.primary.opacity(0.2), /// shadow color
                        radius: 2, /// shadow radius
                        x: 0, /// x offset
                        y: 2 /// y offset
                    )
                
//                NavigationView {
                VStack (alignment: .leading, spacing: 8) {
                        List(resources, id: \.description) { resource in
                            Link(destination: URL(string: resource.url)!) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(resource.description)
                                        .font(.title3)
                                        .fontWeight(.semibold) // Bold for emphasis
                                        .foregroundColor(.black)
                                        .padding(.vertical, 12) // Increased vertical padding
                                    
                                    Text("Click to learn more")
                                        .font(.body)
                                        .foregroundColor(Color.black.opacity(0.7)) // Lighter color for subtle contrast
                                }
//                                .padding()
//                                .fixedSize(horizontal: true, vertical: false)
//                                .background(Color.white.opacity(0.3)) // Solid white background for better readability
//                                .cornerRadius(15) // More pronounced rounded corners
//                                .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 2, y: 2) // Soft blue shadow for depth
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 15)
//                                        .stroke(Color.blue.opacity(0.5), lineWidth: 1) // Blue border for better definition
//                                )
                            }
                        }
//                        .navigationTitle("Helpful Resources")
//                        .navigationBarTitleDisplayMode(.inline)
//                        .listStyle(PlainListStyle()) // Clean list style
                        //                    .background(Color(.systemGroupedBackground)) // Light background for the entire view
                } // VStack
                .padding()
                .background(Color.white.opacity(0.85))
 //               } //NavigationView
            } // Outer VStack
        } //Zstack
    }


    // MARK: - Input Fields
    func inputField(label: String, text: Binding<String>) -> some View {
        HStack (spacing: 3){
            Text("\(label):")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal)
            TextField("Enter \(label.lowercased())", text: text)
                .textFieldStyle(.roundedBorder)
                //.padding()
        }
        .padding(.horizontal)
    }
    
    func lengthWidthInputFields(unit: String) -> some View {
        VStack(spacing: 3) {
            inputField(label: "Length (\(unit))", text: $length)
            inputField(label: "Width (\(unit))", text: $width)
        }
    }
    
    func areaFloorsInputFields(unit: String) -> some View {
        VStack(spacing: 3) {
            inputField(label: "Area (\(unit))", text: $area)
            inputField(label: "Floors", text: $floors)
        }
    }
    
    // MARK: - Calculation Button
    func calculateButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("Calculate")
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(15)
        }
        .padding(.horizontal)
        //.padding(.vertical)
    }
    
    // MARK: - Result Cards
    func resultCard(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .frame(minWidth: 120, maxHeight: .infinity, alignment: .leading)
                
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .frame(maxWidth: .infinity, alignment: .trailing)
                
        }
        //.padding()
        //.background(Color.white)
        //.cornerRadius(15)
        //.shadow(radius: 5)
        //.padding(.horizontal)
    }
    struct ResultCard: View {
        var title: String
        var value: String

        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .lineLimit(nil) // Allow title to wrap
                Text(value)
                    .font(.subheadline)
                    .lineLimit(nil) // Allow value to wrap
            }
            .padding()
            .background(Color.white.opacity(0.85))
            .cornerRadius(15)
            .shadow(radius: 10)
            .frame(maxWidth: .infinity) // Allow full width usage
        }
    }

    // MARK: - Rainwater Calculation Logic
    fileprivate func calculateHistoricalRainwaterHarvestingTrend() {
        let gardenSize: Double = 640.0 // hard-coded to 640 squarefeet. We can accept this as an input
        let weeklyWaterRequirement: Double = gardenSize * 0.623 //Gallons
        /*
        var waterCollected: Double = 0.0
        var totalHarvestedWaterUsedForIrrigation: Double = 0.0
        var numberOfWeeksWateredByRain : Int = 0
        var numberOfWeeksWateredByHarvestedRainwater : Int = 0
        for week in stride(from:0, to: historicalRainData!.daily.rain_sum.count, by: 7) {
            print("** currentWeek \(week)")
            var currWeekRainfall: Double = 0.0
            var currWeekRainCollection: Double = 0.0
            for i in stride(from:week, to:Swift.min(week+7, historicalRainData!.daily.rain_sum.count), by:1) {
                currWeekRainfall += historicalRainData!.daily.rain_sum[i]
            }
            print("  currWeekRainfall \(currWeekRainfall)")
            
            // Total Harvested Rainwater = Rainfall Depth (in) x Catchment Area (ft2) x 0.623 x System % Efficiency
            currWeekRainCollection = currWeekRainfall * roofArea * 0.623  * harvestEfficiency
            print("  currWeekRainCollection \(currWeekRainCollection)")
            
            waterCollected = Swift.min(waterCollected + currWeekRainCollection, waterTankSize)
            print("  waterCollected this week \(waterCollected)")
            
            if (currWeekRainCollection < weeklyWaterRequirement)
            {
                // If current week's rainfall is less than our weekly water requirement then
                // we use the remainder of water from the water tank i.e. subtract the diff from water collected
                
                let thisWeeksWaterRequirement : Double = weeklyWaterRequirement - currWeekRainCollection
                
                let harvestedWaterUsedForIrrigation : Double = thisWeeksWaterRequirement < waterCollected ? thisWeeksWaterRequirement : waterCollected;
                
                print("  harvestedWaterUsedForIrrigation this week \(harvestedWaterUsedForIrrigation)")
                waterCollected -= harvestedWaterUsedForIrrigation  //Now substract the water used for irrigation from waterCollected
                totalHarvestedWaterUsedForIrrigation += harvestedWaterUsedForIrrigation  //Track total harvested water used for irrigation
                
                if (thisWeeksWaterRequirement == harvestedWaterUsedForIrrigation)
                {
                    numberOfWeeksWateredByHarvestedRainwater += 1
                }
            }
            else
            {
                numberOfWeeksWateredByRain += 1
            }
            print("  waterCollected this week after watering plants \(waterCollected)")
        }
        print("*******************************")
        print(" Garden size: \(gardenSize)")
        print(" Weekly water requirement: \(weeklyWaterRequirement)")
        print(" Water tank size: \(waterTankSize)")
        print(" Number of weeks watered by rain in your area: \(numberOfWeeksWateredByRain)")
        print(" Number of weeks watered using harvested rainwater: \(numberOfWeeksWateredByHarvestedRainwater)")
        print(" Total Water Used For Irrigation this year: \(totalHarvestedWaterUsedForIrrigation)")
        print("*******************************")
        */
        rain_data = calculateRainCollectionTrend(rain_sum:historicalRainData!.daily.rain_sum, garden_size: gardenSize, roof_size: roofArea, tank_size: waterTankSize, harvest_efficiency: harvestEfficiency)
    }
    
    func calculateRainCollection(roofArea: Double) {
        guard let latitudeValue = Double(lat),
              let longitudeValue = Double(long) else {
            answer = "Invalid Input"
            return
        }
        Task {
            do {
                //NOTE: getRain method returns rain data in inches if isImperial is true
                //      otherwise, it return rain data in mm (millimeters)
                historicalRainData = try await getRain(latitude: latitudeValue, longitude: longitudeValue, getForecastData: false)
                averageAnnualRainfall = historicalRainData!.daily.rain_sum.reduce(0, +) / 3
                
                print("totalAnnualRainfall \(averageAnnualRainfall)")
                print("Current GPS Long & Lat \(String(describing: locationManager.location?.coordinate.longitude)) and \(String(describing: locationManager.location?.coordinate.latitude))")
                
                var totalRainCollection: Double = 0.0
                
                if (isImperial) {
                    // For Imperial measurement system:
                    // Total Harvested Rainwater = Rainfall Depth (in) x Catchment Area (ft2) x 0.623 x System % Efficiency
                    totalRainCollection = averageAnnualRainfall * roofArea * 0.623  * harvestEfficiency
                }
                else {
                    // For metrics measurement system:
                    // Rainfall (mm) x Roof surface area (m2) = Roof catchment capacity (liters) x System % Efficiency
                    totalRainCollection = averageAnnualRainfall *  roofArea  * harvestEfficiency
                }
                
                answer = String(format: "%.2f", totalRainCollection)
                
                // *********************
                // Calculate water collection potential using historical data
                //
                if (isImperial) {
                    calculateHistoricalRainwaterHarvestingTrend()
                }


                // *********************
                // Calculate forecast data
                let forecastRainData = try await getRain(latitude: latitudeValue, longitude: longitudeValue, getForecastData: true)
                forecastRainfall = forecastRainData.daily.rain_sum.reduce(0, +)
                
                print("forecastRainfall \(forecastRainfall)")
                
                var forecastRainCollection: Double = 0.0
                
                if (isImperial) {
                    // For Imperial measurement system:
                    // Total Harvested Rainwater = Rainfall Depth (in) x Catchment Area (ft2) x 0.623 x System % Efficiency
                    forecastRainCollection = forecastRainfall * roofArea * 0.623  * harvestEfficiency
                }
                else {
                    // For metrics measurement system:
                    // Rainfall (mm) x Roof surface area (m2) = Roof catchment capacity (liters) x System % Efficiency
                    forecastRainCollection = forecastRainfall *  roofArea  * harvestEfficiency
                }
                
                forecastAnswer = String(format: "%.2f", forecastRainCollection)

            } catch {
                answer = "Error fetching rain data"
            }
        }
    }
    
    func calculateRainCollection() {
        guard let lengthValue = Double(length),
              let widthValue = Double(width),
              let latitudeValue = Double(lat),
              let longitudeValue = Double(long) else {
            answer = "Invalid Input"
            return
        }
        roofArea = lengthValue * widthValue
        Task {
            do {
                let rainData = try await getRain(latitude: latitudeValue, longitude: longitudeValue, getForecastData: false)
                averageAnnualRainfall = rainData.daily.rain_sum.reduce(0, +)
                
                print("totalAnnualRainfall \(averageAnnualRainfall)")
                print("Current GPS Long & Lat \(String(describing: locationManager.location?.coordinate.longitude)) and \(String(describing: locationManager.location?.coordinate.latitude))")
                
                // For Imperial measurement system:
                // Total Harvested Rainwater = Rainfall Depth (in) x Catchment Area (ft2) x 0.623 x System % Efficiency
                let totalRainCollection = roofArea * harvestEfficiency * averageAnnualRainfall
                
                answer = String(format: "%.2f", totalRainCollection)
            } catch {
                answer = "Error fetching rain data"
            }
        }
    }
    
    func calculateRainCollectionByArea() {
        guard let areaValue = Double(area),
              let floorsValue = Double(floors),
              let latitudeValue = Double(lat),
              let longitudeValue = Double(long) else {
            answer = "Invalid Input"
            return
        }
        roofArea = areaValue / floorsValue
        Task {
            do {
                let rainData = try await getRain(latitude: latitudeValue, longitude: longitudeValue, getForecastData: false)
                averageAnnualRainfall = rainData.daily.rain_sum.reduce(0, +)
                
                print("totalAnnualRainfall \(averageAnnualRainfall)")
                
                let totalRainCollection = roofArea * harvestEfficiency * averageAnnualRainfall
                answer = String(format: "%.2f", totalRainCollection)
            } catch {
                answer = "Error fetching rain data"
            }
        }
    }
    
    func calculateRainCollectionTrend(rain_sum: [Double], garden_size: Double, roof_size: Double, tank_size: Double, harvest_efficiency: Double ) -> RainWaterCollectionData {
       // var total_rainwater_collected = 0.0
       // var total_water_collected_after_watering = 0.0
    //    let garden_size = 640.0
    //    var roof_size = 2500.0
    //    var harvest_efficiency = 0.75
    //    let tank_size = 900.0
        var tank_water = 0.0
        let water_needed_for_garden = garden_size * 0.623

        var rain_data = RainWaterCollectionData(
            weeklyRainCollectionData: [WeeklyRainwaterCollectionData](),
            gardenSize: garden_size,
            weeklyWaterRequirement: water_needed_for_garden,
            waterTankSize: tank_size,
            numberOfWeeksWateredByRainwater:0,
            totalRainOnGarden: 0.0,
            totalPersonalWaterUsed: 0.0,
            totalHarvestedRainwaterUsed:0.0,
            roofSize: roof_size)
        
        let rain_sum_weeks = rain_sum.chunks(7)
        var weekly_rain = [Double]();

        for week in rain_sum_weeks
        {
            var rain_for_week = 0.0
            for daily_rain_value in week
            {
                rain_for_week = rain_for_week + daily_rain_value
            }
            weekly_rain.append(rain_for_week)
        }


        for i in stride(from: 0, to: weekly_rain.count, by: 1)
        {
            var harvested_water_used_for_irrigation = 0.0
            var self_water_usage = 0.0
            var overflow_water = 0.0

            let rain_on_garden = weekly_rain[i] * 0.623 * garden_size
            let rain_harvested_from_roof = weekly_rain[i] * roof_size * 0.623 * harvest_efficiency
            tank_water = tank_water + rain_harvested_from_roof
            //total_rainwater_collected = total_rainwater_collected + rain_harvested_from_roof
            //total_water_collected_after_watering = total_water_collected_after_watering + rain_harvested_from_roof
            if(tank_water > tank_size)
            {
                overflow_water = (tank_water - tank_size)
                tank_water = tank_size
                
                //subtract overflow_water from the total rainwater collected (which indicates total rainwater collected in tank)
              //  total_rainwater_collected = total_rainwater_collected - overflow_water
            }
           
            if(rain_on_garden >= water_needed_for_garden)
            {
                //abundant of rain this week. No need of extra watering!!
            }
            else if(rain_on_garden < water_needed_for_garden)
            {
                if(tank_water < water_needed_for_garden - rain_on_garden)
                {
                    harvested_water_used_for_irrigation = tank_water
                    //total_water_collected_after_watering = total_water_collected_after_watering - harvested_water_used_for_irrigation
                    self_water_usage = (water_needed_for_garden - rain_on_garden - harvested_water_used_for_irrigation)
                    tank_water  = 0.0
                }
                else
                {
                    tank_water  = tank_water - (water_needed_for_garden - rain_on_garden)
                    harvested_water_used_for_irrigation = water_needed_for_garden - rain_on_garden
                    //total_water_collected_after_watering = total_water_collected_after_watering - harvested_water_used_for_irrigation
                }
            }

            rain_data.weeklyRainCollectionData.append(WeeklyRainwaterCollectionData(
                id:UUID(),
                weekNumber: i + 1,
                rainFall: weekly_rain[i],
                rainCollection: rain_harvested_from_roof,
                rainOnGarden: rain_on_garden,
                harvestedRainwaterUsedForIrrigation: harvested_water_used_for_irrigation,
                overflowWaterAmount: overflow_water,
                tankWater: tank_water,
                personalWaterUsage: self_water_usage))
        }

        
        for i in stride(from: 0, to: rain_data.weeklyRainCollectionData.count, by: 1)
        {
            /*
            print("Week \(rain_data.weeklyRainCollectionData[i].weekNumber)")
            print(" : This Week Rainfall \(rain_data.weeklyRainCollectionData[i].rainFall)")
            print(" : This Week Rain Collection: \(rain_data.weeklyRainCollectionData[i].rainCollection)")
            print(" : This Week Rain on Garden : \(rain_data.weeklyRainCollectionData[i].rainOnGarden)")
            print(" : Harvested Rainwater Used For Irrigation this week: \(rain_data.weeklyRainCollectionData[i].harvestedRainwaterUsedForIrrigation)" )
            print(" : Overflow Water this week: \(rain_data.weeklyRainCollectionData[i].overflowWaterAmount)" )
            print(" : Tank Water, \(rain_data.weeklyRainCollectionData[i].tankWater)" )
            print(" : Personal Water Usage this week: \(rain_data.weeklyRainCollectionData[i].personalWaterUsage)") */
            
            rain_data.totalPersonalWaterUsed = rain_data.totalPersonalWaterUsed + rain_data.weeklyRainCollectionData[i].personalWaterUsage
            rain_data.totalHarvestedRainwaterUsed = rain_data.totalHarvestedRainwaterUsed + rain_data.weeklyRainCollectionData[i].harvestedRainwaterUsedForIrrigation
            rain_data.totalRainOnGarden = rain_data.totalRainOnGarden + rain_data.weeklyRainCollectionData[i].rainOnGarden
            
            if (rain_data.weeklyRainCollectionData[i].personalWaterUsage == 0) {
                rain_data.numberOfWeeksWateredByRainwater = rain_data.numberOfWeeksWateredByRainwater + 1;
            }

            //print(" : Total Rainwater Collected So Far, \(rain_data[i]?.totalWaterCollectedSoFar)" )
            //print(" : Total Water Collected After Irrigation, \(rain_data[i]?.totalWaterCollectedSoFarAfterWateringGarden)" )
        }
        
        print("*******************************")
        print(" Garden size: \(rain_data.gardenSize)")
        print(" Weekly water requirement: \(rain_data.weeklyWaterRequirement)")
        print(" Water tank size: \(rain_data.waterTankSize)")
        print(" Number of weeks watered using harvested rainwater: \(rain_data.numberOfWeeksWateredByRainwater)")
        print(" Total Rain on Garden this year: \(rain_data.totalRainOnGarden)")
        print(" Total Harvested Water Used For Irrigation this year: \(rain_data.totalHarvestedRainwaterUsed)")
        print(" Total Water Personal water used this year: \(rain_data.totalPersonalWaterUsed)")
        print("*******************************")
        
        return rain_data
    }
    
    func waterTankSliderChanged() {
        print("Slider value changed to \(waterTankSize)")
        calculateHistoricalRainwaterHarvestingTrend()
    }
    
    // MARK: - API Request
    func getRain(latitude: Double, longitude: Double, getForecastData:Bool) async throws -> LocationRainfallData {
        //request one whole year's historical rainfall data
        //NOTE: The start_date and end_date is an year apart.
        var endpoint = getForecastData ?
        "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&daily=rain_sum&timezone=GMT&forecast_days=14":
        "https://archive-api.open-meteo.com/v1/archive?latitude=\(latitude)&longitude=\(longitude)&start_date=2024-01-01&end_date=2024-12-31&daily=rain_sum&timezone=GMT"
        
        //NOTE: This method should return rain data in inches if isImperial is true
        //      We do this by appending precipation unit as Inches, if isImperial is true
        //      By default, the API returns precipation data in mm (millimeters)
        if (isImperial)
        {
            endpoint += "&precipitation_unit=inch"
        }
        
        print("Endpoint URL: \(endpoint)")
        
        guard let url = URL(string: endpoint) else { throw ZCError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ZCError.invalidResponse
        }
        // Print the response for debugging purposes.
        print(String(data: data, encoding: .utf8)!)
        
        return try JSONDecoder().decode(LocationRainfallData.self, from: data)
    }
}

// MARK: - Supporting Models and Error Handling
struct LocationRainfallData: Codable {
    let daily: Daily
}

struct Daily: Codable {
    let rain_sum: [Double]
}

enum ZCError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

struct WeeklyRainwaterCollectionData : Identifiable {
    var id: UUID
    
    var weekNumber : Int
    var rainFall : Double                // The value calculated using daily rain data.
    var rainCollection: Double      // In Gallons. NOTE (Hint): This value cannot exceed waterTankSize
    var rainOnGarden : Double
  //  var totalWaterCollectedSoFar: Double       // In Gallons. NOTE (Hint): This value cannot exceed waterTankSize
    var harvestedRainwaterUsedForIrrigation: Double  //In Gallons. NOTE (Hint): If it rains, then you can be smart and not water the garden. Again this value cannot be greater than tank capacity
    //var totalWaterCollectedSoFarAfterWateringGarden: Double // In Gallons. NOTE (HInt): Value between 0 and waterTankSize
    var overflowWaterAmount : Double
    var tankWater : Double
    var personalWaterUsage : Double
}

struct RainWaterCollectionData {
    var weeklyRainCollectionData : [WeeklyRainwaterCollectionData]
    var gardenSize: Double
    var weeklyWaterRequirement: Double
    var waterTankSize: Double
    var numberOfWeeksWateredByRainwater: Int
    var totalRainOnGarden : Double
    var totalPersonalWaterUsed : Double
    var totalHarvestedRainwaterUsed: Double
    var roofSize : Double
}


extension Array {
    func chunks(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

#Preview {
    MenuPage()
        .environmentObject(LocationManager())
}
