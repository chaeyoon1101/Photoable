import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let photoViewController = UINavigationController(rootViewController: PhotoViewController())
        let albumViewController = UINavigationController(rootViewController: AlbumViewController())
        
        photoViewController.tabBarItem.title = "사진"
        photoViewController.tabBarItem.image = UIImage(systemName: "photo.on.rectangle")
        photoViewController.tabBarItem.selectedImage = UIImage(systemName: "photo.fill.on.rectangle.fill")
        
        albumViewController.tabBarItem.title = "앨범"
        albumViewController.tabBarItem.image = UIImage(systemName: "photo.stack")
        albumViewController.tabBarItem.selectedImage = UIImage(systemName: "photo.stack.fill")
        
        viewControllers = [photoViewController, albumViewController]
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
