//
//  AppDelegate.swift
//  Clock
//
//  Created by youseokhwan on 5/20/25.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var diContainer: DIContainer?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        registerAlarmNotificationCategories()

        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions,
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role,
        )
    }

    private func registerAlarmNotificationCategories() {
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE_ACTION", title: "다시 알림", options: [])
        let dismissAction = UNNotificationAction(identifier: "DISMISS_ACTION", title: "중단", options: [.destructive])
        let alarmCategory = UNNotificationCategory(
            identifier: "alarmCategory",
            actions: [snoozeAction, dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        let timerCategory = UNNotificationCategory(
            identifier: "timerCompletion",
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory, timerCategory])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {

        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        let categoryIdentifier = response.notification.request.content.categoryIdentifier

        switch categoryIdentifier {
        case "alarmCategory":
            handleAlarmNotificationResponse(actionIdentifier: actionIdentifier, userInfo: userInfo, completionHandler: completionHandler)
        case "timerCompletion":
            completionHandler()
        default:
            completionHandler()
        }
    }

    private func handleAlarmNotificationResponse(actionIdentifier: String, userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        guard let service = diContainer?.alarmNotificationService,
              let alarmNotification = service.fetch(from: userInfo)
        else {
            completionHandler()

            return
        }

        Task {
            do {
                switch actionIdentifier {
                case "SNOOZE_ACTION":
                    let alarmID = alarmNotification.alarmID
                    let schedulableSnoozeAlarmNotificationUseCase = diContainer!.makeSchedulableSnoozeAlarmNotificationUseCase()
                    try await schedulableSnoozeAlarmNotificationUseCase.execute(
                        alarmID,
                        duration: 5 * 60
                    )
                case "DISMISS_ACTION":
                    let alarmID = alarmNotification.alarmID
                    let cancelableAlarmNotificationUseCase = diContainer!.makeCancelableAlarmNotificationUseCase()
                    await cancelableAlarmNotificationUseCase.execute(alarmID)
                case UNNotificationDefaultActionIdentifier:
                    let alarmID = alarmNotification.alarmID
                    let cancelableAlarmNotificationUseCase = diContainer!.makeCancelableAlarmNotificationUseCase()
                    await cancelableAlarmNotificationUseCase.execute(alarmID)
                default:
                    break
                }
            } catch {}

            completionHandler()
        }
    }
}
