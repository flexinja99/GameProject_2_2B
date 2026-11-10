using System.Collections.Generic;
using Fusion;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;

namespace CoreClash.Lesson01.Course
{
    // 세 강의에서 작성할 네트워크 핵심 코드입니다.
    public class TodoNetworkManager : TodoRunnerCallbacks
    {
        [SerializeField] private GameObject playerPrefab;
        [SerializeField] private TodoRoomUI roomUI;

        private NetworkRunner runner;
        private string localNickname;
        private readonly Dictionary<PlayerRef, NetworkObject> spawnedPlayers = new();

        // 로비, 방 목록, 방 만들기와 입장 
        public async void JoinLobby()
        {
           
        }

        public override void OnSessionListUpdated(NetworkRunner networkRunner, List<SessionInfo> sessionList)
        {
            List<string> rooms = new();
            foreach (SessionInfo session in sessionList)
            {
                if (!session.IsVisible || !session.IsOpen) continue;
                rooms.Add($"{session.Name}  ({session.PlayerCount}/{session.MaxPlayers})");
            }

            roomUI.ShowRooms(rooms);
        }

        public async void StartRoom(string roomName, string nickname, bool createRoom)
        {
            
        }

        // PlayerRef, 권한, Spawn, 닉네임 
        public override void OnPlayerJoined(NetworkRunner networkRunner, PlayerRef player)
        {
           
        }

        public override void OnPlayerLeft(NetworkRunner networkRunner, PlayerRef player)
        {
            if (!spawnedPlayers.TryGetValue(player, out NetworkObject playerObject)) return;

            if (playerObject.HasStateAuthority)
                networkRunner.Despawn(playerObject);
            spawnedPlayers.Remove(player);
        }

        public override void OnShutdown(NetworkRunner networkRunner, ShutdownReason reason)
        {
            spawnedPlayers.Clear();
            roomUI.SetConnected(false);
            roomUI.SetStatus($"연결 종료: {reason}");
            runner = null;
        }

        public async void Disconnect()
        {
            if (runner == null) return;
            await runner.Shutdown();
        }

        // 입력 패킷 전송과 수신
        public override void OnInput(NetworkRunner networkRunner, NetworkInput input)
        {
           
        }

        private static NetworkRunner CreateRunner()
        {
            GameObject runnerObject = new GameObject("TodoNetworkRunner");
            return runnerObject.AddComponent<NetworkRunner>();
        }
    }
}
