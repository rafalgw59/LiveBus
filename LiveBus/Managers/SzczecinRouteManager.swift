import UIKit

protocol RoutesManagerDelegate{
    func didSendRoutesData(_ routesManager: RoutesManager, with routez: [String])
}

struct LinesData: Decodable{
    let route_id: String
}
struct RoutesManager{
    var delegate : RoutesManagerDelegate?
    
    let routesUrl = "https://api.rafalgawlik.net/routes"
    
    func fetchRoutes(){
        let urlString = "https://api.rafalgawlik.net/routes"
        performRequest(with: urlString)
    }
    
    func parseJSON(_ routesData: Data)->[String]?{
        
        let decoder = JSONDecoder()
        
        let routesTable = [String]()
        
        
        do{
            let decodeData = try decoder.decode([String:LinesData].self, from: routesData)
            
            let routesTable = decodeData.keys.sorted {$0.localizedStandardCompare($1) == .orderedAscending}
            
            return routesTable
        } catch {
            print("Error docode the data : \(error.localizedDescription)")
        }
        return routesTable
    }
    
    func performRequest(with urlString: String){
        guard let url = URL(string: urlString) else {fatalError("error")}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data,response,error) in
            
            if error != nil{
                print("error in session task \(String(describing: error?.localizedDescription))")
            } else{
                if let safeData = data{
                    guard let routes = self.parseJSON(safeData) else {fatalError("Error in parsing from JSON")}
                    DispatchQueue.main.async {
                        delegate?.didSendRoutesData(self, with: routes)
                    }
                    
                }
            }
            
            
        }
        task.resume()
    }
}
