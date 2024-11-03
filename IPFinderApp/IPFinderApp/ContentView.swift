//
//  ContentView.swift
//  IPFinderApp
//
//  Created by Gamze Akyüz on 29.10.2024.
//

import SwiftUI
import Network

struct ContentView: View {
    
    //MARK: - Properties
    @State private var localIP: String = "Bulunuyor.."
    @State private var publicIP: String = "Bulunuyor.."
    
    //MARK: - Body
    var body: some View {
        VStack(spacing: 30) {
            
            Text("IP Adres Bulucu")
                .font(.largeTitle)
                .bold()
            
            VStack(alignment: .leading, spacing: 15){
                Text("Yerel IP Adresi : ")
                    .font(.headline)
                Text(localIP)
                    .font(.body)
                    .foregroundColor(.blue)
                Text("Public IP Adresi: ")
                    .font(.headline)
                Text(publicIP)
                    .font(.body)
                    .foregroundColor(.red)
            }
            .padding()
            
            Button("IP Adresini Yenile") {
                fetchLocalIPAddress()
                fetchPublicIPAddress()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
        }
        .onAppear {
            fetchLocalIPAddress()
            fetchPublicIPAddress()
        }
        .padding()
    }
    
    func getLocalIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                let interface = ptr!.pointee
                let addrFamily = interface.ifa_addr.pointee.sa_family

                if addrFamily == AF_INET || addrFamily == AF_INET6 {
                    if let name = String(cString: interface.ifa_name, encoding: .utf8), name == "en0",
                       let sa = interface.ifa_addr {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(sa, socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
                ptr = interface.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
    
    func fetchPublicIPAddress() {
        guard let url = URL(string: "https://api64.ipify.org?format=json") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    publicIP = "Bulunamadı"
                }
                return
            }
            if let result = try? JSONDecoder().decode(IPResponse.self, from: data) {
                DispatchQueue.main.async {
                    publicIP = result.ip
                }
            }
        }.resume()
    }

    struct IPResponse: Codable {
        let ip: String
    }
    
    func fetchLocalIPAddress() {
        if let ip = getLocalIPAddress() {
            localIP = ip
        } else {
            localIP = "Bulunamadı"
        }
    }
    
}


struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
    
}
