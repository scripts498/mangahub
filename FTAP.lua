local ENV = getgenv and getgenv() or _G
local MH = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local LocalPlayer = Players.LocalPlayer

if ENV.MangaFeatureController and ENV.MangaFeatureController.Stop then
    pcall(ENV.MangaFeatureController.Stop)
end

if ENV.MangaHubState then
    ENV.MangaHubState.Running = false

    if ENV.MangaHubState.Connections then
        for _, connection in ipairs(ENV.MangaHubState.Connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
    end

    if ENV.MangaHubState.CharacterConnections then
        for _, connection in ipairs(ENV.MangaHubState.CharacterConnections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
    end

    if ENV.MangaHubState.OwnerConnections then
        for _, connection in pairs(ENV.MangaHubState.OwnerConnections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
    end

end

if ENV.MangaLineController
    and ENV.MangaLineController.Stop
then
    pcall(
        ENV.MangaLineController.Stop
    )
end

if ENV.MangaGrabEffectsController
    and ENV.MangaGrabEffectsController.Stop
then
    pcall(
        ENV.MangaGrabEffectsController.Stop
    )
end

if ENV.MangaMobileThrowController
    and ENV.MangaMobileThrowController.Stop
then
    pcall(
        ENV.MangaMobileThrowController.Stop
    )
end

pcall(function()
    ContextActionService:UnbindAction("MangaHub_MouseDetector")
end)

local Config = {
    ThrowEnabled = false,
    ThrowForce = 400,
    ThrowMin = 50,
    ThrowMax = 15000,
    ThrowFrames = 6,
    MouseMemory = 0.80,

    AntiGrab = true,
    AntiOwnershipSpam = true,
    AntiBurn = false,
    AntiExplosion = false,
    AutoAttacker = false,
    CounterMode = "Repulsion",

    GrabTail = 0.07,
    GrabReleaseTail = 0.00,

    OwnershipQuietTail = 0.06,

    StruggleInterval = 0.018,
    StruggleBurstCount = 6,
    StruggleBurstDelay = 0.008,
    StruggleBurstCooldown = 0.08,
    OwnershipPulseInterval = 0.035,
    StopVelocityInterval = 0.080,

    RagdollResetInterval = 0.080,

    MaxHorizontal = 85,
    MaxVertical = 105,
    MaxAngular = 20,
    MaxVelocityDelta = 75,
    MaxSnapDistance = 5,

    WalkExtra = 16,
    SafeUpVelocity = 58,
    SafeDownVelocity = -70,

    DefenseHardLock = false,
    DefenseLockTail = 0.03,
    DefenseBreakInterval = 0.012,
    DefenseReclaimInterval = 0.40,
    DefenseMaxAssemblies = 1,
    DefenseDriftTolerance = 0.08,
    DefenseMoveStepMultiplier = 1.35,
    DefenseLateralTolerance = 0.08,
    DefenseFrameSnapDistance = 14,
    OwnershipIdleReclaimInterval = 0.18,

    BlobLockHoldTime = 2,
    BlobLockJumpInterval = 0.25,
    BlobBringStickTime = 0.25,
    BlobLoopKick = false,
    BlobDestroyServer = false,
    BlobWhitelistFriends = false,

    LineEnabled = false,
    LineLevel = 0,
    LineInfiniteLevel = 28,
    LineInfiniteReach = 1000000,
    LineR = 255,
    LineG = 0,
    LineB = 0,
    InvisibleLine = false,
    CrazyLine = false,
    LagServer = false,
    LagIntensity = 50,

    KillGrab = false,
    MasslessGrab = false,
    NoclipGrab = false,
    PoisonGrab = false,
    BurnGrab = false,
    RadioactiveGrab = false,
    PerspectiveGrab = false,
    PerspectiveSpeed = 50,
    EspHighlight = false,
    EspBillboard = false,
    EspIcon = true,
    EspFillR = 255,
    EspFillG = 0,
    EspFillB = 0,
    EspFillTransparency = 0.5,
    EspOutlineR = 255,
    EspOutlineG = 255,
    EspOutlineB = 255,
    EspOutlineTransparency = 0,
    EspHighlightMode = "AlwaysOnTop",
    TeleportPlace = "Green House",
    TeleportOffset = 1,
    TeleportBehavior = "Behind",
    LoopTeleport = false,
    LockCamera = false,
    ViewPlayer = false,
    ExplosionEnabled = false,
    ExplosionType = "Firework",
    ExplosionAmount = 1,
    ExplosionDelay = 0,
    ExplosionTarget = "Spawn",
    SnowballAmount = 5,
    AutoMakeSnowball = false,
    PoisonAura = false,
    DeathAura = false,
    RadioactiveAura = false,
    BurnAura = false,
    AttractionAura = false,
    FlingAuraEnabled = false,
    FlingAuraStrength = 400,
    FlingAuraTarget = "Players",
    TelekinesisAura = false,
    TelekinesisMode = "Aura",
    TelekinesisShape = "Blackhole",
    TelekinesisFollowType = "Player",
    TelekinesisTarget = "Players",
    TelekinesisDistance = 10,
    TelekinesisHeight = 10,
    TelekinesisSpeed = 0.01,
    AnchorAura = false,
    AnchorAuraTarget = "Players",
    KickAura = false,
    KickAuraType = "Go to the heaven!",
    AuraWhitelistFriends = false,
    AuraRange = 30,
    KillGrabMaxTime = 2,
    GrabEffectsPulse = 0.05,

    Debug = false
}

State = {
    Running = true,

    Connections = {},
    CharacterConnections = {},
    OwnerConnections = {},

    Character = nil,
    Humanoid = nil,
    Root = nil,
    Head = nil,
    IsHeld = nil,

    HeadPartOwner = nil,

    GrabbedObject = nil,
    OwnerObject = nil,
    Throwing = false,

    LastMouseButton = 0,
    LastMouseTime = 0,
    MobileThrowIntentUntil = 0,
    MobileThrowBoundScript = nil,
    MobileThrowFunction = nil,
    MobileThrowOriginal = nil,

    GrabUntil = 0,

    OwnershipLastSeen = 0,

    LastStruggle = 0,
    LastStopVelocity = 0,
    LastRagdoll = 0,
    LastOwnershipPulse = 0,
    LastBurst = 0,

    BurstRunning = false,

    LastSafeVelocity = Vector3.zero,
    LastSafeCFrame = nil,
    DefenseAnchorVelocity = Vector3.zero,
    DefenseAnchorCFrame = nil,
    DefensePrevCFrame = nil,
    DefenseLockUntil = 0,
    DefenseWasActive = false,
    DefenseNeedsStopVelocity = false,
    DefenseNeedsRagdollReset = false,
    LastDefenseBreak = 0,
    LastDefenseReclaim = 0,
    DefenseOwnershipClaimed = false,
    DefenseGuardPosition = nil,

    InternalFlingDisabled = false,

    BlobPlayerMap = {},
    BlobPlayerSignature = "",
    BlobSelectedPlayer = nil,

    LineTargets = {},
    LineOriginalReach = nil,
    LineBoundScript = nil,
    LineAppliedReach = nil,
    LineFailureNotified = false,
    LineNextRescan = 0,

    GrabEffectTarget = nil,
    GrabEffectTargetPlayer = nil,
    GrabEffectTargetCharacter = nil,
    GrabConstraintOriginal = {},
    GrabCollideOriginal = {},
    KillGrabStarted = 0,
    FeatureWorkerTokens = {},
    FeatureConnections = {},
    FeatureWarnings = {},
    KillGrabActiveGrab = nil,
    KillGrabActivePart = nil,
    KillGrabActivePlayer = nil,
    KillGrabConfirmedFrames = 0,
    KillGrabDoneForGrab = false,
    PerspectiveAnchor = nil,
    PerspectiveActiveGrab = nil,
    PerspectiveSavedRootCFrame = nil,
    PerspectiveSavedCameraSubject = nil,
    PerspectiveSavedCameraType = nil,
    AntiExplosionOriginalAnchored = nil,
    CounterOwnershipLast = 0,
    EspHighlights = {},
    EspBillboards = {},
    EspCharacterConnections = {},
    TeleportSelectedPlayer = nil,
    TeleportPlayerMap = {},
    TeleportRotation = 0,
    TeleportViewSavedSubject = nil,
    ExplosionTrackedToys = {},
    ExplosionSelectedPlayer = nil,
    ExplosionPlayerMap = {},
    AuraControllerRunning = false,
    AuraOwnershipLast = {},
    AuraPartOwnershipLast = {},
    AuraAttractionMovers = {},
    AuraTelekinesisMovers = {},
    AuraAnchorMovers = {},
    AuraFollowPlayer = LocalPlayer,
    AuraFollowPlayerMap = {},
    V14 = {}
}

ENV.MangaHubState = State

if ENV.MangaMouseController
    and ENV.MangaMouseController.Stop
then
    pcall(
        ENV.MangaMouseController.Stop
    )
end

MouseController = {
    Running = true,
    MangaOpen = true,
    RightMouseDown = false,
    Connections = {}
}

ENV.MangaMouseController =
    MouseController

function MH.unlockMouse()
    if not MouseController.Running
        or not State.Running
    then
        return
    end

    UserInputService.MouseBehavior =
        Enum.MouseBehavior.Default

    UserInputService.MouseIconEnabled =
        true
end

function MH.holdRightMouse()
    if not MouseController.Running
        or not State.Running
        or not MouseController.MangaOpen
    then
        return
    end

    MouseController.RightMouseDown =
        true

    UserInputService.MouseBehavior =
        Enum.MouseBehavior.LockCurrentPosition

    UserInputService.MouseIconEnabled =
        false
end

function MH.releaseRightMouse()
    MouseController.RightMouseDown =
        false

    if not MouseController.Running
        or not State.Running
        or not MouseController.MangaOpen
    then
        return
    end

    UserInputService.MouseBehavior =
        Enum.MouseBehavior.Default

    UserInputService.MouseIconEnabled =
        true
end

function MH.closeMangaMouse()
    MouseController.RightMouseDown =
        false

    UserInputService.MouseBehavior =
        Enum.MouseBehavior.LockCenter

    UserInputService.MouseIconEnabled =
        false
end

function MH.openMangaMouse()
    MouseController.RightMouseDown =
        false

    MH.unlockMouse()
end

function MH.stopMouseController()
    if not MouseController.Running then
        return
    end

    MouseController.Running =
        false

    for _, connection in ipairs(
        MouseController.Connections
    ) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(
        MouseController.Connections
    )

    pcall(function()
        RunService:
            UnbindFromRenderStep(
                "MangaHub_MouseUnlock"
            )
    end)

    if ENV.MangaMouseController
        == MouseController
    then
        ENV.MangaMouseController =
            nil
    end
end

MouseController.Stop =
    MH.stopMouseController

table.insert(
    MouseController.Connections,

    UserInputService.InputBegan:
        Connect(function(
            input
        )
            if not MouseController.Running
                or not State.Running
            then
                return
            end

            if input.UserInputType
                == Enum.UserInputType.MouseButton2
            then
                if MouseController.MangaOpen then
                    MH.holdRightMouse()
                end

                return
            end

            if input.KeyCode
                == Enum.KeyCode.N
            then
                if UserInputService:
                    GetFocusedTextBox()
                then
                    return
                end

                MouseController.MangaOpen =
                    not MouseController.MangaOpen

                if MouseController.MangaOpen then
                    MH.openMangaMouse()
                else
                    MH.closeMangaMouse()
                end
            end
        end)
)

table.insert(
    MouseController.Connections,

    UserInputService.InputEnded:
        Connect(function(input)
            if input.UserInputType
                == Enum.UserInputType.MouseButton2
            then
                MH.releaseRightMouse()
            end
        end)
)

RunService:
    BindToRenderStep(
        "MangaHub_MouseUnlock",
        Enum.RenderPriority.Camera.Value + 10,

        function()
            if not MouseController.Running then
                return
            end

            if not State.Running then
                MH.stopMouseController()
                return
            end

            if not MouseController.MangaOpen then
                return
            end

            if MouseController.RightMouseDown then
                if UserInputService.MouseBehavior
                    ~= Enum.MouseBehavior.LockCurrentPosition
                then
                    UserInputService.MouseBehavior =
                        Enum.MouseBehavior.LockCurrentPosition
                end

                UserInputService.MouseIconEnabled =
                    false

                return
            end

            if UserInputService.MouseBehavior
                == Enum.MouseBehavior.LockCenter
            then
                UserInputService.MouseBehavior =
                    Enum.MouseBehavior.Default
            end
        end
    )

MH.unlockMouse()

function MH.log(...)
    if Config.Debug then
        print("[MANGA HUB]", ...)
    end
end

function MH.connect(signal, callback)
    local connection =
        signal:Connect(callback)

    table.insert(
        State.Connections,
        connection
    )

    return connection
end

function MH.connectCharacter(
    signal,
    callback
)
    local connection =
        signal:Connect(callback)

    table.insert(
        State.CharacterConnections,
        connection
    )

    return connection
end

function MH.clearCharacterConnections()
    for _, connection in ipairs(
        State.CharacterConnections
    ) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(
        State.CharacterConnections
    )

    for marker, connection in pairs(
        State.OwnerConnections
    ) do
        pcall(function()
            connection:Disconnect()
        end)

        State.OwnerConnections[marker] =
            nil
    end
end

GrabEvents =
    ReplicatedStorage:
        WaitForChild(
            "GrabEvents"
        )

CreateGrabLine =
    GrabEvents:
        WaitForChild(
            "CreateGrabLine"
        )

SetNetworkOwner =
    GrabEvents:
        WaitForChild(
            "SetNetworkOwner"
        )

DestroyGrabLine =
    GrabEvents:
        WaitForChild(
            "DestroyGrabLine"
        )

EndGrabEarly =
    GrabEvents:
        FindFirstChild(
            "EndGrabEarly"
        )

CharacterEvents =
    ReplicatedStorage:
        WaitForChild(
            "CharacterEvents"
        )

StruggleRemote =
    CharacterEvents:
        WaitForChild(
            "Struggle"
        )

RagdollRemote =
    CharacterEvents:
        FindFirstChild(
            "RagdollRemote"
        )

GameCorrectionEvents =
    ReplicatedStorage:
        FindFirstChild(
            "GameCorrectionEvents"
        )

StopAllVelocity =
    GameCorrectionEvents
        and GameCorrectionEvents:
            FindFirstChild(
                "StopAllVelocity"
            )

MangaUI = nil

do
    local ok, result =
        pcall(function()
            return loadstring(
                game:HttpGet(
                    "https://raw.githubusercontent.com/scripts498/mangahub/main/mangalibrary"
                )
            )()
        end)

    if not ok then
        error(
            "[MANGA HUB] MangaLibrary error:\n"
            .. tostring(result)
        )
    end

    MangaUI =
        result
end

Window =
    MangaUI:CreateWindow({
        Title = "Manga Hub | Arremessando coisas e pessoas | Brasil",
        SubTitle = "by hackmod_01299",
        Theme = "Dark",
        ToggleKey = Enum.KeyCode.N,
        ConfigFolder = "MangaHub"
    })

function MH.valid(object)
    return typeof(object) == "Instance"
        and object.Parent ~= nil
end

function MH.getAssemblyRoot(object)
    if not MH.valid(object) then
        return nil
    end

    if object:IsA("BasePart") then
        return object.AssemblyRootPart
            or object
    end

    if object:IsA("Model") then
        local part =
            object.PrimaryPart
            or object:
                FindFirstChildWhichIsA(
                    "BasePart",
                    true
                )

        if part then
            return part.AssemblyRootPart
                or part
        end
    end

    if object:IsA("Attachment") then
        local parent =
            object.Parent

        if parent
            and parent:IsA(
                "BasePart"
            )
        then
            return parent.AssemblyRootPart
                or parent
        end
    end

    return nil
end

function MH.safeLineCollect(
    output,
    seen,
    source
)
    if type(source) ~= "table" then
        return
    end

    for _, value in pairs(source) do
        if type(value) == "function"
            and not seen[value]
        then
            seen[value] = true
            table.insert(
                output,
                value
            )
        end
    end
end

function MH.lineFunctions()
    local functions = {}
    local seen = {}

    if typeof(getgc)
        == "function"
    then
        local okAll, all =
            pcall(
                getgc,
                true
            )

        if okAll then
            MH.safeLineCollect(
                functions,
                seen,
                all
            )
        end

        local okFunctions, onlyFunctions =
            pcall(
                getgc
            )

        if okFunctions then
            MH.safeLineCollect(
                functions,
                seen,
                onlyFunctions
            )
        end
    end

    if typeof(getreg)
        == "function"
    then
        local ok, registry =
            pcall(
                getreg
            )

        if ok then
            MH.safeLineCollect(
                functions,
                seen,
                registry
            )
        end
    end

    if type(debug)
            == "table"
        and typeof(debug.getregistry)
            == "function"
    then
        local ok, registry =
            pcall(
                debug.getregistry
            )

        if ok then
            MH.safeLineCollect(
                functions,
                seen,
                registry
            )
        end
    end

    return functions
end

function MH.lineUpvalues(fn)
    if typeof(getupvalues)
        == "function"
    then
        local ok, result =
            pcall(
                getupvalues,
                fn
            )

        if ok
            and type(result)
                == "table"
        then
            return result
        end
    end

    if type(debug)
            == "table"
        and typeof(debug.getupvalues)
            == "function"
    then
        local ok, result =
            pcall(
                debug.getupvalues,
                fn
            )

        if ok
            and type(result)
                == "table"
        then
            return result
        end
    end

    return nil
end

function MH.lineSetUpvalue(
    fn,
    index,
    value
)
    if typeof(setupvalue)
        == "function"
    then
        local ok =
            pcall(
                setupvalue,
                fn,
                index,
                value
            )

        if ok then
            return true
        end
    end

    if type(debug)
            == "table"
        and typeof(debug.setupvalue)
            == "function"
    then
        local ok =
            pcall(
                debug.setupvalue,
                fn,
                index,
                value
            )

        if ok then
            return true
        end
    end

    return false
end

function MH.lineFunctionInfo(fn)
    if typeof(getinfo)
        == "function"
    then
        local ok, result =
            pcall(
                getinfo,
                fn
            )

        if ok
            and type(result)
                == "table"
        then
            return result
        end
    end

    if type(debug)
            == "table"
        and typeof(debug.getinfo)
            == "function"
    then
        local ok, result =
            pcall(
                debug.getinfo,
                fn
            )

        if ok
            and type(result)
                == "table"
        then
            return result
        end
    end

    return nil
end

function MH.lineFunctionScript(fn)
    if typeof(getfenv)
        ~= "function"
    then
        return nil
    end

    local ok, environment =
        pcall(
            getfenv,
            fn
        )

    if ok
        and type(environment)
            == "table"
    then
        return environment.script
    end

    return nil
end

function MH.lineCurrentGrabScript()
    local character =
        LocalPlayer.Character

    if not character then
        return nil
    end

    return character:
        FindFirstChild(
            "GrabbingScript",
            true
        )
end

function MH.clearLineBinding()
    State.LineTargets = {}
    State.LineOriginalReach = nil
    State.LineBoundScript = nil
    State.LineAppliedReach = nil
end

function MH.restoreLineReach()
    for _, target in ipairs(
        State.LineTargets
    ) do
        if target.Function
            and target.Index
            and type(target.Original)
                == "number"
        then
            MH.lineSetUpvalue(
                target.Function,
                target.Index,
                target.Original
            )
        end
    end

    State.LineAppliedReach =
        State.LineOriginalReach
end

function MH.lineReachCandidateName(
    name
)
    return name == "grab"
        or name == "distanceChangeScrolling"
        or name == "distanceChangeButtonMoving"
        or name == "distanceChangeButtonToggle"
        or name == ""
end

function MH.locateLineReach()
    local grabbingScript =
        MH.lineCurrentGrabScript()

    if not grabbingScript then
        return false
    end

    if State.LineBoundScript
            == grabbingScript
        and type(State.LineOriginalReach)
            == "number"
        and #State.LineTargets > 0
    then
        return true
    end

    MH.restoreLineReach()
    MH.clearLineBinding()

    local functions =
        MH.lineFunctions()

    local grabFunction
    local baseReach

    for _, fn in ipairs(functions) do
        if MH.lineFunctionScript(fn)
            == grabbingScript
        then
            local info =
                MH.lineFunctionInfo(fn)

            local name =
                info
                and tostring(
                    info.name
                        or ""
                )
                or ""

            if name == "grab" then
                local values =
                    MH.lineUpvalues(fn)

                if values
                    and type(values[17])
                        == "number"
                then
                    grabFunction = fn
                    baseReach =
                        values[17]
                    break
                end
            end
        end
    end

    if not grabFunction
        or type(baseReach)
            ~= "number"
    then
        return false
    end

    local targets = {}

    for _, fn in ipairs(functions) do
        if MH.lineFunctionScript(fn)
            == grabbingScript
        then
            local info =
                MH.lineFunctionInfo(fn)

            local name =
                info
                and tostring(
                    info.name
                        or ""
                )
                or ""

            if MH.lineReachCandidateName(
                name
            )
            then
                local values =
                    MH.lineUpvalues(fn)

                if values then
                    for index,
                        value
                    in pairs(values) do
                        if type(value)
                                == "number"
                            and value
                                == baseReach
                        then
                            table.insert(
                                targets,
                                {
                                    Function = fn,
                                    Index = index,
                                    Original = value,
                                    Name = name
                                }
                            )
                        end
                    end
                end
            end
        end
    end

    if #targets <= 0 then
        return false
    end

    State.LineTargets =
        targets

    State.LineOriginalReach =
        baseReach

    State.LineBoundScript =
        grabbingScript

    State.LineAppliedReach =
        baseReach

    State.LineFailureNotified =
        false

    return true
end

function MH.lineTargetExists(
    fn,
    index
)
    for _, entry in ipairs(
        State.LineTargets
    ) do
        if entry.Function == fn
            and entry.Index == index
        then
            return true
        end
    end

    return false
end

function MH.refreshLineTargets()
    local grabbingScript =
        MH.lineCurrentGrabScript()

    if not grabbingScript then
        return false,
            0
    end

    if State.LineBoundScript
            ~= grabbingScript
        or type(State.LineOriginalReach)
            ~= "number"
        or #State.LineTargets <= 0
    then
        return MH.locateLineReach(),
            0
    end

    local functions =
        MH.lineFunctions()

    local added = 0

    for _, fn in ipairs(functions) do
        if MH.lineFunctionScript(fn)
            == grabbingScript
        then
            local info =
                MH.lineFunctionInfo(fn)

            local name =
                info
                and tostring(
                    info.name
                        or ""
                )
                or ""

            if MH.lineReachCandidateName(
                name
            )
            then
                local values =
                    MH.lineUpvalues(fn)

                if values then
                    for index,
                        value
                    in pairs(values) do
                        if type(value)
                                == "number"
                            and value
                                == State.LineOriginalReach
                            and not MH.lineTargetExists(
                                fn,
                                index
                            )
                        then
                            table.insert(
                                State.LineTargets,
                                {
                                    Function = fn,
                                    Index = index,
                                    Original = value,
                                    Name = name
                                }
                            )

                            added += 1
                        end
                    end
                end
            end
        end
    end

    return #State.LineTargets > 0,
        added
end

function MH.lineTargetReach()
    if not MH.locateLineReach() then
        return nil
    end

    local level =
        math.clamp(
            math.floor(
                Config.LineLevel
                    + 0.5
            ),
            0,
            Config.LineInfiniteLevel
        )

    if level <= 0 then
        return State.LineOriginalReach
    end

    if level
        >= Config.LineInfiniteLevel
    then
        return Config.LineInfiniteReach
    end

    return State.LineOriginalReach
        * (level + 1)
end

function MH.applyLineReach()
    if not Config.LineEnabled then
        MH.restoreLineReach()
        return true,
            State.LineOriginalReach
    end

    local target =
        MH.lineTargetReach()

    if not target then
        return false,
            nil
    end

    local applied = 0

    for _, entry in ipairs(
        State.LineTargets
    ) do
        if MH.lineSetUpvalue(
            entry.Function,
            entry.Index,
            target
        )
        then
            applied += 1
        end
    end

    local ok =
        applied
            == #State.LineTargets
        and applied > 0

    if ok then
        State.LineAppliedReach =
            target
    end

    return ok,
        target
end

LineController = {}

function LineController.Stop()
    Config.LineEnabled = false

    MH.restoreLineReach()

    if ENV.MangaLineController
        == LineController
    then
        ENV.MangaLineController = nil
    end
end

ENV.MangaLineController =
    LineController

task.spawn(function()
    while State.Running do
        if Config.LineEnabled then
            local currentScript =
                MH.lineCurrentGrabScript()

            if currentScript
                and currentScript
                    ~= State.LineBoundScript
            then
                MH.restoreLineReach()
                MH.clearLineBinding()
                State.LineNextRescan = 0
            end

            local now =
                os.clock()

            if now
                >= State.LineNextRescan
            then
                State.LineNextRescan =
                    now + 0.75

                MH.refreshLineTargets()
            end

            local ok =
                MH.applyLineReach()

            if not ok
                and not State.LineFailureNotified
            then
                State.LineFailureNotified =
                    true

                Window:Notify({
                    Title = "Line",
                    Text = "Não consegui aplicar os limites internos da Grab Line.",
                    Duration = 4
                })
            end
        end

        task.wait(0.20)
    end

    MH.restoreLineReach()

    if ENV.MangaLineController
        == LineController
    then
        ENV.MangaLineController = nil
    end
end)

function State.V14.getActiveGrabContext()
    local grabParts = Workspace:FindFirstChild("GrabParts")
    local grabPart = grabParts and grabParts:FindFirstChild("GrabPart")
    local weld = grabPart and grabPart:FindFirstChild("WeldConstraint")
    local part = weld and weld.Part1
    local character = part and part:FindFirstAncestorOfClass("Model")
    local player = character and Players:GetPlayerFromCharacter(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not grabParts or not part or not character or not player or not humanoid then
        return nil, nil, nil, nil, nil
    end

    return grabParts, part, character, player, humanoid
end

function State.V14.isPlayerLocallyOwned(player)
    local character = player and player.Character
    local head = character and character:FindFirstChild("Head")
    local owner = head and head:FindFirstChild("PartOwner")
    return owner ~= nil and owner.Value == LocalPlayer.Name
end

function State.V14.isPartLocallyOwned(part)
    local owner = part and part:FindFirstChild("PartOwner")
    return owner ~= nil and owner.Value == LocalPlayer.Name
end

function State.V14.newWorkerToken(name)
    local token = (State.FeatureWorkerTokens[name] or 0) + 1
    State.FeatureWorkerTokens[name] = token
    return token
end

function State.V14.workerTokenAlive(name, token)
    return State.Running and State.FeatureWorkerTokens[name] == token
end

function State.V14.cancelWorker(name)
    State.FeatureWorkerTokens[name] = (State.FeatureWorkerTokens[name] or 0) + 1
end

function State.V14.trackFeatureConnection(bucketName, connection)
    if not connection then
        return nil
    end
    local bucket = State.FeatureConnections[bucketName]
    if not bucket then
        bucket = {}
        State.FeatureConnections[bucketName] = bucket
    end
    table.insert(bucket, connection)
    return connection
end

function State.V14.disconnectFeatureBucket(bucketName)
    local bucket = State.FeatureConnections[bucketName]
    if not bucket then
        return
    end
    for _, connection in ipairs(bucket) do
        if typeof(connection) == "RBXScriptConnection" then
            pcall(function()
                connection:Disconnect()
            end)
        end
    end
    State.FeatureConnections[bucketName] = nil
end

function MH.restoreGrabMassless()
    for constraint, saved in pairs(
        State.GrabConstraintOriginal
    ) do
        if constraint
            and constraint.Parent
        then
            for property, value in pairs(
                saved
            ) do
                pcall(function()
                    constraint[property] = value
                end)
            end
        end
    end

    State.GrabConstraintOriginal = {}
end

function MH.saveGrabConstraintProperty(
    constraint,
    property
)
    local saved =
        State.GrabConstraintOriginal[
            constraint
        ]

    if not saved then
        saved = {}
        State.GrabConstraintOriginal[
            constraint
        ] = saved
    end

    if saved[property] ~= nil then
        return true
    end

    local ok, value =
        pcall(function()
            return constraint[property]
        end)

    if not ok then
        return false
    end

    saved[property] = value
    return true
end

function MH.setGrabConstraintProperty(
    constraint,
    property,
    value
)
    if not MH.saveGrabConstraintProperty(
        constraint,
        property
    ) then
        return false
    end

    return pcall(function()
        constraint[property] = value
    end)
end

function MH.applyMasslessGrabConstraints()
    local grabParts =
        Workspace:
            FindFirstChild(
                "GrabParts"
            )

    if not grabParts then
        MH.restoreGrabMassless()
        return false
    end

    local applied = false

    for _, name in ipairs({
        "DragPart",
        "DragPart1"
    }) do
        local dragPart =
            grabParts:
                FindFirstChild(
                    name
                )
            or grabParts:
                FindFirstChild(
                    name,
                    true
                )

        if dragPart then
            local alignOrientation =
                dragPart:
                    FindFirstChildWhichIsA(
                        "AlignOrientation"
                    )

            if alignOrientation then
                MH.setGrabConstraintProperty(
                    alignOrientation,
                    "MaxAngularVelocity",
                    math.huge
                )

                MH.setGrabConstraintProperty(
                    alignOrientation,
                    "MaxTorque",
                    math.huge
                )

                MH.setGrabConstraintProperty(
                    alignOrientation,
                    "Responsiveness",
                    200
                )

                applied = true
            end

            local alignPosition =
                dragPart:
                    FindFirstChildWhichIsA(
                        "AlignPosition"
                    )

            if alignPosition then
                MH.setGrabConstraintProperty(
                    alignPosition,
                    "MaxAxesForce",
                    Vector3.new(
                        math.huge,
                        math.huge,
                        math.huge
                    )
                )

                MH.setGrabConstraintProperty(
                    alignPosition,
                    "MaxForce",
                    math.huge
                )

                MH.setGrabConstraintProperty(
                    alignPosition,
                    "MaxVelocity",
                    math.huge
                )

                MH.setGrabConstraintProperty(
                    alignPosition,
                    "Responsiveness",
                    200
                )

                applied = true
            end
        end
    end

    return applied
end

function MH.restoreGrabCollisions()
    for part, original in pairs(
        State.GrabCollideOriginal
    ) do
        if part
            and part.Parent
        then
            pcall(function()
                part.CanCollide = original
            end)
        end
    end

    State.GrabCollideOriginal = {}
end

function State.V14.resetKillGrabState()
    State.KillGrabActiveGrab = nil
    State.KillGrabActivePart = nil
    State.KillGrabActivePlayer = nil
    State.KillGrabStarted = 0
    State.KillGrabConfirmedFrames = 0
    State.KillGrabDoneForGrab = false
end

function MH.restoreGrabEffectParts()
    MH.restoreGrabMassless()
    MH.restoreGrabCollisions()
    State.V14.resetKillGrabState()
end

function MH.resetGrabEffectsTransient()
    MH.restoreGrabCollisions()
    State.GrabEffectTarget = nil
    State.GrabEffectTargetPlayer = nil
    State.GrabEffectTargetCharacter = nil
    State.V14.resetKillGrabState()
end

function MH.currentGrabEffectPart()
    local grabParts =
        Workspace:
            FindFirstChild(
                "GrabParts"
            )

    if not grabParts then
        return nil
    end

    local grabPart =
        grabParts:
            FindFirstChild(
                "GrabPart"
            )

    if not grabPart then
        return nil
    end

    local weld =
        grabPart:
            FindFirstChild(
                "WeldConstraint"
            )
        or grabPart:
            FindFirstChildWhichIsA(
                "WeldConstraint"
            )

    if weld
        and MH.valid(weld.Part1)
    then
        return weld.Part1
    end

    return nil
end

function MH.grabEffectPlayerFromPart(
    part
)
    local current = part

    while current
        and current ~= Workspace
    do
        if current:IsA("Model") then
            local player =
                Players:
                    GetPlayerFromCharacter(
                        current
                    )

            if player then
                return player,
                    current
            end
        end

        current = current.Parent
    end

    return nil,
        nil
end

function MH.grabEffectContainer(
    part,
    character
)
    if character then
        return character
    end

    if not MH.valid(part) then
        return nil
    end

    if part:IsA("Model") then
        return part
    end

    local current =
        part.Parent

    while current
        and current ~= Workspace
    do
        if current:IsA("Model") then
            if Workspace:
                    FindFirstChild(
                        "Map"
                    )
                and current:IsDescendantOf(
                    Workspace.Map
                )
            then
                break
            end

            return current
        end

        current = current.Parent
    end

    return part
end

function MH.appendGrabEffectPart(
    list,
    seen,
    part
)
    if part
        and part:IsA("BasePart")
        and part.Parent
        and not seen[part]
    then
        seen[part] = true
        table.insert(
            list,
            part
        )
    end
end

function MH.grabNoclipParts(
    part,
    character
)
    local result = {}
    local seen = {}

    if character then
        for _, descendant in ipairs(
            character:GetDescendants()
        ) do
            MH.appendGrabEffectPart(
                result,
                seen,
                descendant
            )
        end

        return result
    end

    if not MH.valid(part)
        or not part:IsA(
            "BasePart"
        )
    then
        return result
    end

    local grabParts =
        Workspace:
            FindFirstChild(
                "GrabParts"
            )

    local targetInMap =
        Workspace:
            FindFirstChild(
                "Map"
            )
        and part:IsDescendantOf(
            Workspace.Map
        )

    local function allowed(
        candidate
    )
        if not candidate
            or not candidate:IsA(
                "BasePart"
            )
            or not candidate.Parent
        then
            return false
        end

        if grabParts
            and candidate:IsDescendantOf(
                grabParts
            )
        then
            return false
        end

        local candidatePlayer =
            MH.grabEffectPlayerFromPart(
                candidate
            )

        if candidatePlayer then
            return false
        end

        if candidate.Anchored then
            return false
        end

        if Workspace:
                FindFirstChild(
                    "Map"
                )
            and candidate:IsDescendantOf(
                Workspace.Map
            )
            and not targetInMap
        then
            return false
        end

        return true
    end

    local queue = {}
    local queued = {}

    if allowed(part) then
        table.insert(
            queue,
            part
        )
        queued[part] = true
    end

    local index = 1

    while index <= #queue
        and #result < 256
    do
        local current =
            queue[index]
        index = index + 1

        MH.appendGrabEffectPart(
            result,
            seen,
            current
        )

        local ok, linked =
            pcall(function()
                return current:
                    GetConnectedParts(
                        false
                    )
            end)

        if ok
            and type(linked)
                == "table"
        then
            for _, candidate in ipairs(
                linked
            ) do
                if not queued[candidate]
                    and allowed(
                        candidate
                    )
                then
                    queued[candidate] =
                        true

                    table.insert(
                        queue,
                        candidate
                    )
                end
            end
        end
    end

    return result
end

function MH.applyGrabNoclip(
    parts
)
    for _, part in ipairs(parts) do
        if State.GrabCollideOriginal[part]
            == nil
        then
            State.GrabCollideOriginal[part] =
                part.CanCollide
        end

        pcall(function()
            part.CanCollide = false
        end)
    end
end

function State.V14.warnFeatureOnce(key, text)
    if State.FeatureWarnings[key] then
        return
    end
    State.FeatureWarnings[key] = true
    pcall(function()
        Window:Notify({
            Title = "Feature",
            Text = text,
            Duration = 4
        })
    end)
end

function State.V14.getPoisonGrabParts()
    local map = Workspace:FindFirstChild("Map")
    local result = {}
    if not map then
        return result
    end

    local hole = map:FindFirstChild("Hole")
    local big = hole and hole:FindFirstChild("PoisonBigHole")
    local small = hole and hole:FindFirstChild("PoisonSmallHole")
    local factory = map:FindFirstChild("FactoryIsland")
    local container = factory and factory:FindFirstChild("PoisonContainer")

    for _, part in ipairs({
        big and big:FindFirstChild("PoisonHurtPart"),
        small and small:FindFirstChild("PoisonHurtPart"),
        container and container:FindFirstChild("PoisonHurtPart")
    }) do
        if part and part:IsA("BasePart") then
            table.insert(result, part)
        end
    end

    return result
end

function State.V14.getBurnCarrierPart()
    local folder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    if not folder then
        return nil
    end

    for _, descendant in ipairs(folder:GetDescendants()) do
        if descendant.Name == "FirePlayerPart" and descendant:IsA("BasePart") then
            return descendant
        end
    end

    return nil
end

function State.V14.getRadioactiveGrabPart()
    local map = Workspace:FindFirstChild("Map")
    local always = map and map:FindFirstChild("AlwaysHereTweenedObjects")
    local outer = always and always:FindFirstChild("OuterUFO")
    local object = outer and outer:FindFirstChild("Object")
    local model = object and object:FindFirstChild("ObjectModel")
    local part = model and model:FindFirstChild("PaintPlayerPart")
    if part and part:IsA("BasePart") then
        return part
    end
    return nil
end

function State.V14.pulseFeaturePartAt(part, targetPart)
    if not part or not part.Parent or not targetPart or not targetPart.Parent then
        return false
    end

    local savedCFrame = part.CFrame
    local savedAnchored = part.Anchored
    local weld = part:FindFirstChild("WeldConstraint")
    local savedWeldEnabled = weld and weld.Enabled

    pcall(function()
        if weld then
            weld.Enabled = false
        end
        part.Anchored = true
        part.CFrame = targetPart.CFrame
    end)

    task.defer(function()
        RunService.Heartbeat:Wait()
        if part and part.Parent then
            pcall(function()
                part.CFrame = savedCFrame
                part.Anchored = savedAnchored
                if weld and weld.Parent and savedWeldEnabled ~= nil then
                    weld.Enabled = savedWeldEnabled
                end
            end)
        end
    end)

    return true
end

function State.V14.applyPoisonGrab(character)
    local head = character and character:FindFirstChild("Head")
    if not head then
        return false
    end
    local parts = State.V14.getPoisonGrabParts()
    if #parts == 0 then
        State.V14.warnFeatureOnce("PoisonGrab", "Poison parts are unavailable on this map.")
        return false
    end
    local applied = false
    for _, part in ipairs(parts) do
        applied = State.V14.pulseFeaturePartAt(part, head) or applied
    end
    return applied
end

function State.V14.applyBurnGrab(character)
    local target = character and character:FindFirstChild("HumanoidRootPart")
    local carrier = State.V14.getBurnCarrierPart()
    if not target or not carrier then
        if not carrier then
            State.V14.warnFeatureOnce("BurnGrab", "No fire carrier is available in your spawned toys.")
        end
        return false
    end
    return State.V14.pulseFeaturePartAt(carrier, target)
end

function State.V14.applyRadioactiveGrab(character)
    local target = character and character:FindFirstChild("HumanoidRootPart")
    local carrier = State.V14.getRadioactiveGrabPart()
    if not target or not carrier then
        if not carrier then
            State.V14.warnFeatureOnce("RadioactiveGrab", "Radioactive map part is unavailable.")
        end
        return false
    end
    return State.V14.pulseFeaturePartAt(carrier, target)
end

function State.V14.stopPerspectiveGrab()
    State.V14.disconnectFeatureBucket("PerspectiveGrab")

    local camera = Workspace.CurrentCamera
    if camera then
        if State.PerspectiveSavedCameraSubject and State.PerspectiveSavedCameraSubject.Parent then
            camera.CameraSubject = State.PerspectiveSavedCameraSubject
        elseif State.Humanoid and State.Humanoid.Parent then
            camera.CameraSubject = State.Humanoid
        end
        if State.PerspectiveSavedCameraType then
            camera.CameraType = State.PerspectiveSavedCameraType
        else
            camera.CameraType = Enum.CameraType.Custom
        end
    end

    if State.Root and State.Root.Parent and State.PerspectiveSavedRootCFrame then
        pcall(function()
            State.Root.CFrame = State.PerspectiveSavedRootCFrame
        end)
    end

    if State.PerspectiveAnchor and State.PerspectiveAnchor.Parent then
        State.PerspectiveAnchor:Destroy()
    end

    State.PerspectiveAnchor = nil
    State.PerspectiveActiveGrab = nil
    State.PerspectiveSavedRootCFrame = nil
    State.PerspectiveSavedCameraSubject = nil
    State.PerspectiveSavedCameraType = nil
end

function State.V14.startPerspectiveGrab(grabParts, part)
    if not Config.PerspectiveGrab or not grabParts or not part or part.Anchored then
        State.V14.stopPerspectiveGrab()
        return false
    end

    if State.PerspectiveActiveGrab == grabParts and State.PerspectiveAnchor and State.PerspectiveAnchor.Parent then
        return true
    end

    State.V14.stopPerspectiveGrab()

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local camera = Workspace.CurrentCamera
    if not humanoid or not root or not camera then
        return false
    end

    local anchor = Instance.new("Part")
    anchor.Name = "MangaPerspectiveAnchor"
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.CanQuery = false
    anchor.Transparency = 1
    anchor.Size = Vector3.new(0.05, 0.05, 0.05)
    anchor.CFrame = camera.CFrame
    anchor.Parent = Workspace

    State.PerspectiveAnchor = anchor
    State.PerspectiveActiveGrab = grabParts
    State.PerspectiveSavedRootCFrame = root.CFrame
    State.PerspectiveSavedCameraSubject = camera.CameraSubject
    State.PerspectiveSavedCameraType = camera.CameraType

    camera.CameraType = Enum.CameraType.Follow
    camera.CameraSubject = anchor
    pcall(function()
        root.CFrame = CFrame.new(527, 123, -376)
    end)

    State.V14.trackFeatureConnection("PerspectiveGrab", RunService.Heartbeat:Connect(function(dt)
        if not Config.PerspectiveGrab
            or not State.Running
            or State.PerspectiveActiveGrab ~= grabParts
            or not grabParts.Parent
            or not anchor.Parent
        then
            State.V14.stopPerspectiveGrab()
            return
        end

        local activeGrabParts, activePart = State.V14.getActiveGrabContext()
        if activeGrabParts ~= grabParts or activePart ~= part then
            State.V14.stopPerspectiveGrab()
            return
        end

        local move = humanoid.MoveDirection
        if move.Magnitude > 0 then
            anchor.CFrame = anchor.CFrame + move * Config.PerspectiveSpeed * dt
        end
    end))

    return true
end

function MH.applyKillGrab(
    grabParts,
    part,
    player,
    character,
    humanoid
)
    if not grabParts
        or not part
        or not player
        or player == LocalPlayer
        or not character
        or not humanoid
        or not character.Parent
        or not part.Parent
    then
        State.V14.resetKillGrabState()
        return false
    end

    if State.KillGrabActiveGrab ~= grabParts
        or State.KillGrabActivePart ~= part
        or State.KillGrabActivePlayer ~= player
    then
        State.KillGrabActiveGrab = grabParts
        State.KillGrabActivePart = part
        State.KillGrabActivePlayer = player
        State.KillGrabStarted = os.clock()
        State.KillGrabConfirmedFrames = 0
        State.KillGrabDoneForGrab = false
    end

    if State.KillGrabDoneForGrab then
        return false
    end

    if os.clock() - State.KillGrabStarted >= Config.KillGrabMaxTime then
        State.KillGrabDoneForGrab = true
        State.KillGrabConfirmedFrames = 0
        return false
    end

    if not State.V14.isPlayerLocallyOwned(player) then
        State.KillGrabConfirmedFrames = 0
        return false
    end

    pcall(function()
        humanoid.BreakJointsOnDeath = false
        humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        humanoid.Jump = true
        humanoid.Sit = false
    end)

    local stateOk, currentState = pcall(function()
        return humanoid:GetState()
    end)

    if stateOk and currentState == Enum.HumanoidStateType.Dead then
        State.KillGrabConfirmedFrames = State.KillGrabConfirmedFrames + 1
    else
        State.KillGrabConfirmedFrames = 0
    end

    if State.KillGrabConfirmedFrames >= 2 then
        local currentGrabParts, currentPart, _, currentPlayer, currentHumanoid =
            State.V14.getActiveGrabContext()

        if currentGrabParts == grabParts
            and currentPart == part
            and currentPlayer == player
            and currentHumanoid == humanoid
        then
            DestroyGrabLine:FireServer(part)
            State.KillGrabDoneForGrab = true
            return true
        end

        State.V14.resetKillGrabState()
    end

    return false
end

function MH.updateGrabEffects()
    if Config.MasslessGrab then
        MH.applyMasslessGrabConstraints()
    else
        MH.restoreGrabMassless()
    end

    local part =
        MH.currentGrabEffectPart()

    if not MH.valid(part) then
        State.V14.stopPerspectiveGrab()
        if State.GrabEffectTarget
                ~= nil
            or next(
                State.GrabCollideOriginal
            )
        then
            MH.resetGrabEffectsTransient()
        end

        return
    end

    local player,
        character =
        MH.grabEffectPlayerFromPart(
            part
        )

    local targetIdentity =
        character
        or MH.getAssemblyRoot(part)
        or part

    if State.GrabEffectTarget
        ~= targetIdentity
    then
        MH.resetGrabEffectsTransient()

        State.GrabEffectTarget =
            targetIdentity
        State.GrabEffectTargetPlayer =
            player
        State.GrabEffectTargetCharacter =
            character
        State.V14.resetKillGrabState()
    end

    if Config.NoclipGrab then
        local parts =
            MH.grabNoclipParts(
                part,
                character
            )

        MH.applyGrabNoclip(
            parts
        )
    else
        MH.restoreGrabCollisions()
    end

    if player and character then
        if Config.PoisonGrab then
            State.V14.applyPoisonGrab(character)
        end
        if Config.BurnGrab then
            State.V14.applyBurnGrab(character)
        end
        if Config.RadioactiveGrab then
            State.V14.applyRadioactiveGrab(character)
        end
    end

    if Config.PerspectiveGrab then
        local perspectiveGrabParts, perspectivePart = State.V14.getActiveGrabContext()
        if perspectiveGrabParts and perspectivePart == part then
            State.V14.startPerspectiveGrab(perspectiveGrabParts, perspectivePart)
        end
    else
        State.V14.stopPerspectiveGrab()
    end

    if Config.KillGrab then
        local killGrabParts, killPart, killCharacter, killPlayer, killHumanoid =
            State.V14.getActiveGrabContext()

        if killGrabParts
            and killPart == part
            and killPlayer
            and killPlayer ~= LocalPlayer
            and killCharacter
            and killHumanoid
        then
            MH.applyKillGrab(
                killGrabParts,
                killPart,
                killPlayer,
                killCharacter,
                killHumanoid
            )
        elseif State.KillGrabActiveGrab ~= nil then
            State.V14.resetKillGrabState()
        end
    elseif State.KillGrabActiveGrab ~= nil then
        State.V14.resetKillGrabState()
    end
end

GrabEffectsController = {}

function GrabEffectsController.Stop()
    Config.KillGrab = false
    Config.MasslessGrab = false
    Config.NoclipGrab = false
    Config.PoisonGrab = false
    Config.BurnGrab = false
    Config.RadioactiveGrab = false
    Config.PerspectiveGrab = false

    State.V14.stopPerspectiveGrab()
    MH.resetGrabEffectsTransient()
    State.V14.resetKillGrabState()

    if ENV.MangaGrabEffectsController
        == GrabEffectsController
    then
        ENV.MangaGrabEffectsController = nil
    end
end

ENV.MangaGrabEffectsController =
    GrabEffectsController

task.spawn(function()
    while State.Running do
        if Config.KillGrab
            or Config.MasslessGrab
            or Config.NoclipGrab
            or Config.PoisonGrab
            or Config.BurnGrab
            or Config.RadioactiveGrab
            or Config.PerspectiveGrab
        then
            MH.updateGrabEffects()
        elseif State.GrabEffectTarget
            or next(State.GrabConstraintOriginal)
            or next(State.GrabCollideOriginal)
        then
            MH.resetGrabEffectsTransient()
        end

        task.wait(
            Config.GrabEffectsPulse
        )
    end

    MH.resetGrabEffectsTransient()
    State.V14.resetKillGrabState()

    if ENV.MangaGrabEffectsController
        == GrabEffectsController
    then
        ENV.MangaGrabEffectsController = nil
    end
end)

function MH.refreshCorrectionRemotes()
    if not GameCorrectionEvents
        or not GameCorrectionEvents.Parent
    then
        GameCorrectionEvents =
            ReplicatedStorage:
                FindFirstChild(
                    "GameCorrectionEvents"
                )
    end

    if GameCorrectionEvents
        and (
            not StopAllVelocity
            or not StopAllVelocity.Parent
        )
    then
        StopAllVelocity =
            GameCorrectionEvents:
                FindFirstChild(
                    "StopAllVelocity"
                )
    end

    if not RagdollRemote
        or not RagdollRemote.Parent
    then
        RagdollRemote =
            CharacterEvents:
                FindFirstChild(
                    "RagdollRemote"
                )
    end
end

function MH.findIsHeld()
    local held =
        LocalPlayer:
            FindFirstChild(
                "IsHeld",
                true
            )

    if held then
        return held
    end

    local character =
        LocalPlayer.Character

    if character then
        return character:
            FindFirstChild(
                "IsHeld",
                true
            )
    end

    return nil
end

function MH.getHeadPartOwner()
    local head =
        State.Head

    if not head
        or not head.Parent
    then
        return nil
    end

    return head:
        FindFirstChild(
            "PartOwner"
        )
end

function MH.markerValue(marker)
    if not marker
        or not marker.Parent
    then
        return nil
    end

    local ok, value =
        pcall(function()
            return marker.Value
        end)

    if ok then
        return value
    end

    return nil
end

function MH.markerHostile(marker)
    if not marker
        or not marker.Parent
    then
        return false
    end

    local value =
        MH.markerValue(marker)

    if typeof(value)
        == "string"
    then
        if value == "" then
            return true
        end

        return string.lower(
            value
        ) ~= string.lower(
            LocalPlayer.Name
        )
    end

    if typeof(value)
        == "number"
    then
        return value
            ~= LocalPlayer.UserId
    end

    if typeof(value)
        == "Instance"
    then
        if value
            == LocalPlayer
            or value
                == LocalPlayer.Character
        then
            return false
        end

        if LocalPlayer.Character
            and value:
                IsDescendantOf(
                    LocalPlayer.Character
                )
        then
            return false
        end

        return true
    end

    return true
end

function MH.armDefenseWindow(duration)
    local now = os.clock()
    local root = State.Root

    if not State.DefenseWasActive
        or now >= State.DefenseLockUntil
    then
        State.DefenseAnchorCFrame =
            State.LastSafeCFrame
            or (root and root.Parent and root.CFrame)
            or nil

        State.DefenseAnchorVelocity =
            State.LastSafeVelocity
            or Vector3.zero
    end

    State.DefenseWasActive = true
    State.DefenseLockUntil =
        math.max(
            State.DefenseLockUntil,
            now + (duration or Config.DefenseLockTail)
        )
end

function MH.activateGrab()
    MH.armDefenseWindow(
        Config.GrabTail
            + Config.DefenseLockTail
    )

    State.GrabUntil =
        math.max(
            State.GrabUntil,
            os.clock()
                + Config.GrabTail
        )
end

function MH.grabActive()
    return Config.AntiGrab
        and os.clock()
            < State.GrabUntil
end

function MH.ownershipMarkerActive()
    if not Config.AntiOwnershipSpam then
        return false
    end

    local marker =
        MH.getHeadPartOwner()

    return marker
        and MH.markerHostile(
            marker
        )
        or false
end

function MH.ownershipActive()
    if not Config.AntiOwnershipSpam then
        return false
    end

    if MH.ownershipMarkerActive() then
        return true
    end

    return os.clock()
        - State.OwnershipLastSeen
        <= Config.OwnershipQuietTail
end

function MH.isHeld()
    local held =
        State.IsHeld

    return Config.AntiGrab
        and held
        and held.Parent
        and held:IsA(
            "BoolValue"
        )
        and held.Value == true
end

function MH.defenseActive()
    return MH.grabActive()
        or MH.isHeld()
end

function MH.fireStruggle()
    if not State.Running then
        return
    end

    pcall(function()
        StruggleRemote:
            FireServer(
                LocalPlayer
            )
    end)
end

function MH.fireStopVelocity()
    MH.refreshCorrectionRemotes()

    if not StopAllVelocity then
        return
    end

    pcall(function()
        StopAllVelocity:
            FireServer()
    end)
end

function MH.fireRagdollReset()
    MH.refreshCorrectionRemotes()

    if not RagdollRemote then
        return
    end

    local root =
        State.Root

    if not root
        or not root.Parent
    then
        return
    end

    local now =
        os.clock()

    if now
        - State.LastRagdoll
        < Config.RagdollResetInterval
    then
        return
    end

    State.LastRagdoll =
        now

    pcall(function()
        RagdollRemote:
            FireServer(
                root,
                0
            )
    end)
end

function MH.struggleBurst()
    local now = os.clock()

    if State.BurstRunning
        or now - State.LastBurst < Config.StruggleBurstCooldown
    then
        return
    end

    State.LastBurst = now
    State.BurstRunning = true

    task.spawn(function()
        for _ = 1,
            Config.StruggleBurstCount
        do
            if not State.Running then
                break
            end

            if not MH.isHeld()
                and not MH.grabActive()
            then
                break
            end

            MH.fireStruggle()

            task.wait(
                Config.StruggleBurstDelay
            )
        end

        State.BurstRunning = false
    end)
end

function MH.restoreHumanoid()
    local humanoid = State.Humanoid
    local root = State.Root

    if not humanoid
        or humanoid.Health <= 0
    then
        return
    end

    pcall(function()
        humanoid:SetStateEnabled(
            Enum.HumanoidStateType.Jumping,
            true
        )
    end)

    if root
        and root.Parent
        and root.Anchored
    then
        pcall(function()
            root.Anchored = false
        end)
    end

    if humanoid.Sit
        and humanoid.SeatPart == nil
    then
        humanoid.Sit = false
    end

    if humanoid.PlatformStand then
        humanoid.PlatformStand = false
    end

    humanoid.AutoRotate = true

    local humanoidState = humanoid:GetState()

    if humanoidState == Enum.HumanoidStateType.Physics
        or humanoidState == Enum.HumanoidStateType.Ragdoll
        or humanoidState == Enum.HumanoidStateType.FallingDown
        or humanoidState == Enum.HumanoidStateType.GettingUp
    then
        pcall(function()
            if humanoid.FloorMaterial
                ~= Enum.Material.Air
            then
                humanoid:ChangeState(
                    Enum.HumanoidStateType.Running
                )
            else
                humanoid:ChangeState(
                    Enum.HumanoidStateType.Freefall
                )
            end
        end)
    end
end

function MH.fireStruggleLimited(force)
    local now = os.clock()

    if not force
        and now - State.LastStruggle < Config.StruggleInterval
    then
        return false
    end

    State.LastStruggle = now
    MH.fireStruggle()
    return true
end

function MH.fireStopVelocityLimited(force)
    local now = os.clock()

    if not force
        and now - State.LastStopVelocity < Config.StopVelocityInterval
    then
        return false
    end

    State.LastStopVelocity = now
    MH.fireStopVelocity()
    return true
end

function MH.getSafeDefenseVelocity()
    local root = State.Root
    local humanoid = State.Humanoid

    if not root or not humanoid then
        return Vector3.zero
    end

    local current = root.AssemblyLinearVelocity
    local movement = humanoid.MoveDirection
    local walkSpeed = math.max(humanoid.WalkSpeed, 0)
    local horizontalLimit = math.min(
        walkSpeed + Config.WalkExtra,
        Config.MaxHorizontal
    )
    local horizontal

    if movement.Magnitude > 0.01 then
        horizontal = movement.Unit * horizontalLimit
    else
        horizontal = Vector3.zero
    end

    local vertical = current.Y
    local previousY = State.LastSafeVelocity.Y

    if vertical > Config.MaxVertical
        or vertical - previousY > Config.MaxVelocityDelta
    then
        vertical = math.clamp(
            previousY,
            0,
            Config.SafeUpVelocity
        )
    elseif vertical < -Config.MaxVertical
        or previousY - vertical > Config.MaxVelocityDelta
    then
        vertical = math.clamp(
            previousY,
            Config.SafeDownVelocity,
            0
        )
    end

    return Vector3.new(
        horizontal.X,
        vertical,
        horizontal.Z
    )
end

function MH.recordSafePhysics()
    local root = State.Root

    if not root
        or not root.Parent
        or MH.defenseActive()
        or MH.isHeld()
    then
        return
    end

    State.LastSafeVelocity =
        root.AssemblyLinearVelocity

    State.LastSafeCFrame =
        root.CFrame

    State.DefenseAnchorVelocity =
        State.LastSafeVelocity

    State.DefenseAnchorCFrame =
        State.LastSafeCFrame

    State.DefenseWasActive =
        false

    State.DefensePrevCFrame =
        root.CFrame

    State.DefenseNeedsStopVelocity =
        false

    State.DefenseNeedsRagdollReset =
        false
end

function MH.releaseDefense()
    local root = State.Root
    local humanoid = State.Humanoid

    State.GrabUntil = 0
    State.DefenseLockUntil = 0
    State.DefenseWasActive = false
    State.DefenseNeedsStopVelocity = false
    State.DefenseNeedsRagdollReset = false
    State.LastDefenseBreak = 0
    State.LastDefenseReclaim = 0
    State.DefenseOwnershipClaimed = false
    State.DefenseGuardPosition = nil
    State.OwnershipLastSeen = -math.huge

    if root and root.Parent and root.Anchored then
        pcall(function()
            root.Anchored = false
        end)
    end

    if humanoid
        and humanoid.Parent
        and humanoid.Health > 0
    then
        pcall(function()
            humanoid:SetStateEnabled(
                Enum.HumanoidStateType.Jumping,
                true
            )

            humanoid.PlatformStand = false
            humanoid.AutoRotate = true

            if humanoid.Sit
                and humanoid.SeatPart == nil
            then
                humanoid.Sit = false
            end

            local state = humanoid:GetState()

            if state == Enum.HumanoidStateType.Physics
                or state == Enum.HumanoidStateType.Ragdoll
                or state == Enum.HumanoidStateType.FallingDown
                or state == Enum.HumanoidStateType.GettingUp
            then
                if humanoid.FloorMaterial ~= Enum.Material.Air then
                    humanoid:ChangeState(
                        Enum.HumanoidStateType.Running
                    )
                else
                    humanoid:ChangeState(
                        Enum.HumanoidStateType.Freefall
                    )
                end
            end
        end)
    end

    if root and root.Parent then
        State.LastSafeVelocity =
            root.AssemblyLinearVelocity

        State.LastSafeCFrame =
            root.CFrame

        State.DefenseAnchorVelocity =
            root.AssemblyLinearVelocity

        State.DefenseAnchorCFrame =
            root.CFrame

        State.DefensePrevCFrame =
            root.CFrame
    end
end

function MH.localCharacterPart(part)
    return part
        and part:IsA("BasePart")
        and State.Character
        and part:IsDescendantOf(
            State.Character
        )
end

function MH.disableLocalGrabConstraints()
    if not Config.AntiGrab then
        return false
    end

    local character = State.Character

    if not character
        or not character.Parent
    then
        return false
    end

    local grabParts =
        Workspace:
            FindFirstChild(
                "GrabParts"
            )

    if not grabParts then
        return false
    end

    local broke = false

    for _, object in ipairs(
        grabParts:GetDescendants()
    ) do
        if object:IsA(
            "WeldConstraint"
        ) then
            local part0 =
                object.Part0

            local part1 =
                object.Part1

            local target

            if MH.localCharacterPart(
                part0
            ) then
                target = part0
            elseif MH.localCharacterPart(
                part1
            ) then
                target = part1
            end

            if target then
                broke = true

                pcall(function()
                    object.Enabled = false
                end)
            end
        elseif object:IsA(
            "Weld"
        ) then
            local part0 =
                object.Part0

            local part1 =
                object.Part1

            if MH.localCharacterPart(part0)
                or MH.localCharacterPart(part1)
            then
                broke = true

                pcall(function()
                    object.Enabled = false
                end)
            end
        end
    end

    return broke
end

function MH.breakIncomingGrab(force)
    if not Config.AntiGrab
        and not Config.AntiOwnershipSpam
    then
        return false
    end

    local broke =
        MH.disableLocalGrabConstraints()

    local now = os.clock()

    if not force
        and now - State.LastDefenseBreak
            < Config.DefenseBreakInterval
    then
        return broke
    end

    State.LastDefenseBreak = now

    local root = State.Root
    local head = State.Head

    if root and root.Parent then
        pcall(function()
            DestroyGrabLine:
                FireServer(root)
        end)
    end

    if head and head.Parent then
        pcall(function()
            DestroyGrabLine:
                FireServer(head)
        end)
    end

    local grabParts =
        Workspace:
            FindFirstChild(
                "GrabParts"
            )

    if grabParts then
        for _, object in ipairs(
            grabParts:GetDescendants()
        ) do
            if object:IsA(
                "WeldConstraint"
            ) then
                local part0 =
                    object.Part0

                local part1 =
                    object.Part1

                local target

                if MH.localCharacterPart(
                    part0
                ) then
                    target = part0
                elseif MH.localCharacterPart(
                    part1
                ) then
                    target = part1
                end

                if target then
                    broke = true

                    pcall(function()
                        object.Enabled = false
                    end)

                    pcall(function()
                        DestroyGrabLine:
                            FireServer(
                                target
                            )
                    end)
                end
            end
        end
    end

    return broke
end

function MH.reclaimLocalOwnership(force)
    if not Config.AntiOwnershipSpam
        and not Config.AntiGrab
    then
        return false
    end

    if State.DefenseOwnershipClaimed then
        return false
    end

    if not MH.isHeld()
        and not MH.grabActive()
    then
        return false
    end

    local now = os.clock()

    if not force
        and now - State.LastDefenseReclaim
            < Config.DefenseReclaimInterval
    then
        return false
    end

    State.LastDefenseReclaim = now

    local root = State.Root

    if not root
        or not root.Parent
    then
        return false
    end

    local assembly =
        root.AssemblyRootPart
        or root

    local ok = pcall(function()
        SetNetworkOwner:
            FireServer(
                assembly,
                assembly.CFrame
            )
    end)

    if ok then
        State.DefenseOwnershipClaimed = true
    end

    return ok
end

function MH.zeroCharacterAssemblies()
    local character =
        State.Character

    if not character
        or not character.Parent
    then
        return
    end

    local seen = {}

    for _, object in ipairs(
        character:GetDescendants()
    ) do
        if object:IsA(
            "BasePart"
        ) then
            local assembly =
                object.AssemblyRootPart
                or object

            if assembly
                and assembly.Parent
                and not seen[assembly]
            then
                seen[assembly] = true

                pcall(function()
                    assembly.AssemblyAngularVelocity =
                        Vector3.zero

                    assembly.AssemblyLinearVelocity =
                        Vector3.zero
                end)
            end
        end
    end
end


function MH.guardGrabDisplacement(dt)
    if not MH.isHeld()
        and not MH.grabActive()
    then
        State.DefenseGuardPosition = nil
        return false
    end

    local root = State.Root
    local humanoid = State.Humanoid

    if not root
        or not root.Parent
        or not humanoid
        or humanoid.Health <= 0
    then
        return false
    end

    MH.disableLocalGrabConstraints()

    local velocity =
        root.AssemblyLinearVelocity

    local movement =
        humanoid.MoveDirection

    local horizontalMovement =
        Vector3.new(
            movement.X,
            0,
            movement.Z
        )

    local targetHorizontal =
        Vector3.zero

    if horizontalMovement.Magnitude
        > 0.01
    then
        local walkSpeed =
            math.max(
                humanoid.WalkSpeed,
                0
            )

        targetHorizontal =
            horizontalMovement.Unit
            * walkSpeed
    end

    local currentHorizontal =
        Vector3.new(
            velocity.X,
            0,
            velocity.Z
        )

    local error =
        (
            currentHorizontal
            - targetHorizontal
        ).Magnitude

    local shouldCorrect =
        MH.isHeld()
        or MH.ownershipMarkerActive()
        or error > 2.5

    if shouldCorrect then
        pcall(function()
            root.AssemblyLinearVelocity =
                Vector3.new(
                    targetHorizontal.X,
                    velocity.Y,
                    targetHorizontal.Z
                )

            if root.AssemblyAngularVelocity.Magnitude
                > 1.5
            then
                root.AssemblyAngularVelocity =
                    Vector3.zero
            end
        end)
    end

    return shouldCorrect
end

function MH.sanitizeDefensePhysics()
    if not MH.defenseActive()
        and not MH.isHeld()
    then
        State.DefenseNeedsStopVelocity = false
        State.DefenseNeedsRagdollReset = false
        MH.recordSafePhysics()
        return false
    end

    local root = State.Root
    local humanoid = State.Humanoid

    if not root
        or not root.Parent
        or not humanoid
        or humanoid.Health <= 0
    then
        State.DefenseNeedsStopVelocity = false
        State.DefenseNeedsRagdollReset = false
        return false
    end

    MH.disableLocalGrabConstraints()

    local velocity =
        root.AssemblyLinearVelocity

    local angular =
        root.AssemblyAngularVelocity

    local horizontal =
        Vector3.new(
            velocity.X,
            0,
            velocity.Z
        )

    local stateNow =
        humanoid:GetState()

    local badState =
        stateNow
            == Enum.HumanoidStateType.Physics
        or stateNow
            == Enum.HumanoidStateType.Ragdoll
        or stateNow
            == Enum.HumanoidStateType.FallingDown

    local movement =
        humanoid.MoveDirection

    local horizontalMovement =
        Vector3.new(
            movement.X,
            0,
            movement.Z
        )

    local targetHorizontal =
        Vector3.zero

    if horizontalMovement.Magnitude
        > 0.01
    then
        targetHorizontal =
            horizontalMovement.Unit
            * math.max(
                humanoid.WalkSpeed,
                0
            )
    end

    local horizontalError =
        (
            horizontal
            - targetHorizontal
        ).Magnitude

    local severeLinear =
        horizontal.Magnitude
            > Config.MaxHorizontal
        or math.abs(velocity.Y)
            > Config.MaxVertical

    local angularSuspicious =
        angular.Magnitude
            > Config.MaxAngular

    local movementHijacked =
        (
            MH.isHeld()
            or MH.ownershipMarkerActive()
        )
        and horizontalError > 2.5

    if movementHijacked then
        pcall(function()
            root.AssemblyLinearVelocity =
                Vector3.new(
                    targetHorizontal.X,
                    velocity.Y,
                    targetHorizontal.Z
                )
        end)
    elseif severeLinear then
        local safeY =
            math.clamp(
                velocity.Y,
                Config.SafeDownVelocity,
                Config.SafeUpVelocity
            )

        pcall(function()
            root.AssemblyLinearVelocity =
                Vector3.new(
                    targetHorizontal.X,
                    safeY,
                    targetHorizontal.Z
                )
        end)
    end

    if angularSuspicious
        or (
            MH.isHeld()
            and angular.Magnitude > 1.5
        )
    then
        pcall(function()
            root.AssemblyAngularVelocity =
                Vector3.zero
        end)
    end

    if badState
        or humanoid.PlatformStand
        or (
            humanoid.Sit
            and humanoid.SeatPart == nil
        )
    then
        MH.restoreHumanoid()
    end

    State.DefensePrevCFrame =
        root.CFrame

    State.DefenseAnchorVelocity =
        root.AssemblyLinearVelocity

    State.DefenseNeedsStopVelocity =
        false

    State.DefenseNeedsRagdollReset =
        badState
        or humanoid.PlatformStand
        or (
            humanoid.Sit
            and humanoid.SeatPart == nil
        )

    return movementHijacked
        or severeLinear
        or angularSuspicious
        or badState
        or humanoid.PlatformStand
        or (
            humanoid.Sit
            and humanoid.SeatPart == nil
        )
end

function State.V14.getExtinguishPart()
    local map = Workspace:FindFirstChild("Map")
    local hole = map and map:FindFirstChild("Hole")
    local big = hole and hole:FindFirstChild("PoisonBigHole")
    local part = big and big:FindFirstChild("ExtinguishPart")
    if part and part:IsA("BasePart") then
        return part
    end
    return nil
end

function State.V14.resolveOwnerPlayer(marker)
    local value = MH.markerValue(marker)
    if typeof(value) == "string" then
        return Players:FindFirstChild(value)
    end
    if typeof(value) == "number" then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.UserId == value then
                return player
            end
        end
    end
    if typeof(value) == "Instance" then
        if value:IsA("Player") then
            return value
        end
        local model = value:FindFirstAncestorOfClass("Model")
        if model then
            return Players:GetPlayerFromCharacter(model)
        end
    end
    return nil
end

function State.V14.boundedCounterOwnershipRequest(player, root)
    if State.V14.isPlayerLocallyOwned(player) then
        return true
    end
    if os.clock() - State.CounterOwnershipLast < 0.25 then
        return false
    end
    local myRoot = State.Root
    if not myRoot or not root or (myRoot.Position - root.Position).Magnitude > 30 then
        return false
    end
    State.CounterOwnershipLast = os.clock()
    pcall(function()
        SetNetworkOwner:FireServer(root, root.CFrame)
    end)
    return State.V14.isPlayerLocallyOwned(player)
end

function State.V14.applyCounterAttack(attackerPlayer)
    if not Config.AutoAttacker or not attackerPlayer or attackerPlayer == LocalPlayer then
        return false
    end

    local character = attackerPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        return false
    end

    if not State.V14.boundedCounterOwnershipRequest(attackerPlayer, root) then
        return false
    end

    if Config.CounterMode == "Repulsion" then
        local myRoot = State.Root
        if not myRoot then
            return false
        end
        local delta = root.Position - myRoot.Position
        local direction = delta.Magnitude > 0.01 and delta.Unit or Vector3.new(0, 1, 0)
        local velocity = Instance.new("BodyVelocity")
        velocity.Name = "MangaCounterRepulsion"
        velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        velocity.Velocity = Vector3.new(direction.X * 100, 50, direction.Z * 100)
        velocity.Parent = root
        task.delay(0.12, function()
            if velocity.Parent then
                velocity:Destroy()
            end
        end)
        return true
    end

    if Config.CounterMode == "Freeze" then
        local walk = humanoid.WalkSpeed
        local jump = humanoid.JumpPower
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        humanoid.Sit = false
        task.delay(0.18, function()
            if humanoid.Parent then
                humanoid.WalkSpeed = walk
                humanoid.JumpPower = jump
            end
        end)
        return true
    end

    if Config.CounterMode == "Death" then
        pcall(function()
            humanoid.BreakJointsOnDeath = false
            humanoid:ChangeState(Enum.HumanoidStateType.Dead)
            humanoid.Jump = true
            humanoid.Sit = false
        end)
        return true
    end

    if Config.CounterMode == "Kick" then
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.new(0, 1000000, 0)
            DestroyGrabLine:FireServer(root)
        end)
        return true
    end

    return false
end

function State.V14.pulseAntiBurn()
    if not Config.AntiBurn then
        return
    end
    local root = State.Root
    local firePart = root and root:FindFirstChild("FirePlayerPart")
    local canBurn = firePart and firePart:FindFirstChild("CanBurn")
    if not firePart or not canBurn or not canBurn.Value then
        return
    end
    local extinguish = State.V14.getExtinguishPart()
    if not extinguish then
        State.V14.warnFeatureOnce("AntiBurn", "ExtinguishPart is unavailable on this map.")
        return
    end
    if typeof(firetouchinterest) == "function" then
        pcall(function()
            firetouchinterest(firePart, extinguish, 0)
            firetouchinterest(firePart, extinguish, 1)
        end)
    else
        State.V14.pulseFeaturePartAt(extinguish, firePart)
    end
end

function State.V14.pulseAntiExplosion()
    local root = State.Root
    local humanoid = State.Humanoid
    local ragdolled = humanoid and humanoid:FindFirstChild("Ragdolled")
    local active = Config.AntiExplosion and root and ragdolled and ragdolled.Value and not MH.isHeld()

    if active then
        if State.AntiExplosionOriginalAnchored == nil then
            State.AntiExplosionOriginalAnchored = root.Anchored
        end
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.Anchored = true
    elseif root and State.AntiExplosionOriginalAnchored ~= nil then
        root.Anchored = State.AntiExplosionOriginalAnchored
        State.AntiExplosionOriginalAnchored = nil
    end
end

State.V14.InvincibilityController = { Running = true }

function State.V14.InvincibilityController.Stop()
    State.V14.InvincibilityController.Running = false
    Config.AntiBurn = false
    Config.AntiExplosion = false
    Config.AutoAttacker = false
    State.V14.pulseAntiExplosion()
    if ENV.MangaInvincibilityController == State.V14.InvincibilityController then
        ENV.MangaInvincibilityController = nil
    end
end

if ENV.MangaInvincibilityController and ENV.MangaInvincibilityController.Stop then
    pcall(ENV.MangaInvincibilityController.Stop)
end
ENV.MangaInvincibilityController = State.V14.InvincibilityController

task.spawn(function()
    while State.Running and State.V14.InvincibilityController.Running do
        State.V14.pulseAntiBurn()
        State.V14.pulseAntiExplosion()
        if Config.AutoAttacker then
            local marker = MH.getHeadPartOwner()
            if marker and MH.markerHostile(marker) then
                local attacker = State.V14.resolveOwnerPlayer(marker)
                if attacker then
                    State.V14.applyCounterAttack(attacker)
                end
            end
        end
        task.wait(0.05)
    end
    State.V14.pulseAntiExplosion()
end)

function MH.ownershipPulse()
    if not Config.AntiOwnershipSpam then
        return
    end

    local now = os.clock()
    State.OwnershipLastSeen = now

    local heldNow = MH.isHeld()

    if heldNow then
        MH.activateGrab()
    end

    if now - State.LastOwnershipPulse
        < Config.OwnershipPulseInterval
    then
        if heldNow then
            MH.sanitizeDefensePhysics()
        end
        return
    end

    State.LastOwnershipPulse = now

    if not heldNow then
        return
    end

    MH.breakIncomingGrab(false)
    MH.fireStruggleLimited(false)

    local attacked =
        MH.sanitizeDefensePhysics()

    if attacked
        and State.DefenseNeedsRagdollReset
    then
        MH.fireRagdollReset()
    end

    MH.struggleBurst()
end

function MH.grabPulse()
    if not Config.AntiGrab then
        return
    end

    local firstPulse =
        not State.DefenseWasActive
        or not State.DefenseOwnershipClaimed

    MH.activateGrab()

    if firstPulse then
        MH.reclaimLocalOwnership(true)
    end

    MH.breakIncomingGrab(true)
    MH.fireStruggleLimited(true)

    local attacked =
        MH.sanitizeDefensePhysics()

    if attacked
        and State.DefenseNeedsRagdollReset
    then
        MH.fireRagdollReset()
    end

    MH.struggleBurst()

    task.defer(function()
        if not State.Running
            or not MH.isHeld()
        then
            return
        end

        MH.breakIncomingGrab(true)
        MH.fireStruggleLimited(true)
    end)
end

function MH.registerHeadPartOwner(
    marker
)
    if not marker
        or marker.Name
            ~= "PartOwner"
        or marker.Parent
            ~= State.Head
    then
        return
    end

    State.HeadPartOwner =
        marker

    local old =
        State.OwnerConnections[
            marker
        ]

    if old then
        pcall(function()
            old:Disconnect()
        end)
    end

    local ok, connection =
        pcall(function()
            return marker:
                GetPropertyChangedSignal(
                    "Value"
                ):
                Connect(function()
                    if not State.Running
                        or not Config.AntiOwnershipSpam
                    then
                        return
                    end

                    if MH.markerHostile(
                        marker
                    ) then
                        MH.ownershipPulse()
                    end
                end)
        end)

    if ok
        and connection
    then
        State.OwnerConnections[
            marker
        ] = connection
    end

    if MH.markerHostile(
        marker
    ) then
        MH.ownershipPulse()
    end
end

function MH.unregisterHeadPartOwner(
    marker
)
    local connection =
        State.OwnerConnections[
            marker
        ]

    if connection then
        pcall(function()
            connection:
                Disconnect()
        end)

        State.OwnerConnections[
            marker
        ] = nil
    end

    if State.HeadPartOwner
        == marker
    then
        State.HeadPartOwner =
            nil
    end

    State.OwnershipLastSeen =
        os.clock()
end

function MH.scanHeadOwner()
    local marker =
        MH.getHeadPartOwner()

    if marker
        and marker
            ~= State.HeadPartOwner
    then
        MH.registerHeadPartOwner(
            marker
        )
    end

    return marker
end

function MH.disableInternalFlingHandler()
    if State.InternalFlingDisabled then
        return
    end

    if not State.IsHeld then
        return
    end

    if typeof(getconnections)
            ~= "function"
        or typeof(getfenv)
            ~= "function"
    then
        return
    end

    local targetScript =
        State.Character
        and State.Character:
            FindFirstChild(
                "HumanoidStateTypeByGettingFlung",
                true
            )

    local ok, connections =
        pcall(
            getconnections,
            State.IsHeld.Changed
        )

    if not ok
        or type(connections)
            ~= "table"
    then
        return
    end

    local disabled =
        false

    for _, connection in ipairs(
        connections
    ) do
        local fn

        pcall(function()
            fn =
                connection.Function
        end)

        if fn then
            local success,
                environment =
                pcall(
                    getfenv,
                    fn
                )

            if success
                and type(environment)
                    == "table"
            then
                local scriptObject =
                    environment.script

                if scriptObject
                    and (
                        scriptObject
                            == targetScript
                        or scriptObject.Name
                            == "HumanoidStateTypeByGettingFlung"
                    )
                then
                    local disabledOk =
                        pcall(function()
                            connection:
                                Disable()
                        end)

                    if disabledOk then
                        disabled =
                            true
                    end
                end
            end
        end
    end

    if disabled then
        State.InternalFlingDisabled =
            true
    end
end

function MH.setupCharacter(
    character
)
    MH.clearCharacterConnections()

    State.Character =
        character

    State.Humanoid =
        character:
            WaitForChild(
                "Humanoid",
                10
            )

    if State.Humanoid then
        pcall(function()
            State.Humanoid:SetStateEnabled(
                Enum.HumanoidStateType.Jumping,
                true
            )
        end)
    end

    State.Root =
        character:
            WaitForChild(
                "HumanoidRootPart",
                10
            )

    State.Head =
        character:
            WaitForChild(
                "Head",
                10
            )

    State.IsHeld =
        MH.findIsHeld()

    State.HeadPartOwner =
        nil

    State.GrabUntil =
        0

    State.OwnershipLastSeen =
        -math.huge

    State.LastStruggle = 0
    State.LastStopVelocity = 0
    State.LastRagdoll = 0
    State.LastOwnershipPulse = 0
    State.LastBurst = 0
    State.LastDefenseBreak = 0
    State.LastDefenseReclaim = 0
    State.DefenseOwnershipClaimed = false
    State.DefenseGuardPosition = nil
    State.DefenseLockUntil = 0
    State.DefenseWasActive = false
    State.DefenseNeedsStopVelocity = false
    State.DefenseNeedsRagdollReset = false
    State.DefensePrevCFrame = nil
    State.InternalFlingDisabled = false

    if State.Root then
        State.LastSafeVelocity = State.Root.AssemblyLinearVelocity
        State.LastSafeCFrame = State.Root.CFrame
        State.DefenseAnchorVelocity = State.LastSafeVelocity
        State.DefenseAnchorCFrame = State.LastSafeCFrame
        State.DefensePrevCFrame = State.Root.CFrame
    else
        State.LastSafeVelocity = Vector3.zero
        State.LastSafeCFrame = nil
        State.DefenseAnchorVelocity = Vector3.zero
        State.DefenseAnchorCFrame = nil
        State.DefensePrevCFrame = nil
    end

    MH.scanHeadOwner()

    task.defer(
        MH.disableInternalFlingHandler
    )

    task.delay(
        0.20,
        MH.disableInternalFlingHandler
    )

    task.delay(
        0.75,
        MH.disableInternalFlingHandler
    )

    if State.IsHeld
        and State.IsHeld:IsA(
            "BoolValue"
        )
    then
        MH.connectCharacter(
            State.IsHeld:
                GetPropertyChangedSignal(
                    "Value"
                ),

            function()
                if not State.Running
                    or not Config.AntiGrab
                then
                    return
                end

                if State.IsHeld.Value then
                    MH.grabPulse()
                else
                    MH.releaseDefense()
                end
            end
        )
    end

    if State.Humanoid then
        MH.connectCharacter(
            State.Humanoid:
                GetPropertyChangedSignal(
                    "Sit"
                ),

            function()
                if not State.Running
                    or not Config.AntiGrab
                then
                    return
                end

                if State.Humanoid.Sit
                    and State.Humanoid.SeatPart
                        == nil
                then
                    MH.grabPulse()

                    State.Humanoid.Sit =
                        false
                end
            end
        )

        MH.connectCharacter(
            State.Humanoid.StateChanged,

            function(
                oldState,
                newState
            )
                if not State.Running then
                    return
                end

                if (
                    newState
                        == Enum.HumanoidStateType.Physics
                    or newState
                        == Enum.HumanoidStateType.Ragdoll
                    or newState
                        == Enum.HumanoidStateType.FallingDown
                )
                    and State.Humanoid.SeatPart
                        == nil
                    and MH.defenseActive()
                then
                    MH.restoreHumanoid()

                    local attacked = MH.sanitizeDefensePhysics()
                    MH.fireStruggleLimited(false)

                    if attacked
                        and State.DefenseNeedsRagdollReset
                    then
                        MH.fireRagdollReset()
                    end
                end
            end
        )
    end

    if State.Head then
        MH.connectCharacter(
            State.Head.ChildAdded,

            function(object)
                if not State.Running
                    or not Config.AntiOwnershipSpam
                then
                    return
                end

                if object.Name
                    == "PartOwner"
                then
                    MH.registerHeadPartOwner(
                        object
                    )
                end
            end
        )

        MH.connectCharacter(
            State.Head.ChildRemoved,

            function(object)
                if object.Name
                    == "PartOwner"
                then
                    MH.unregisterHeadPartOwner(
                        object
                    )
                end
            end
        )
    end

end

if LocalPlayer.Character then
    task.spawn(
        MH.setupCharacter,
        LocalPlayer.Character
    )
end

MH.connect(
    LocalPlayer.CharacterAdded,

    function(character)
        MH.resetGrabEffectsTransient()

        State.MobileThrowIntentUntil =
            0

        task.spawn(
            MH.setupCharacter,
            character
        )
    end
)

MH.connect(
    Workspace.DescendantAdded,

    function(object)
        if not State.Running
            or not Config.AntiGrab
            or not State.Character
        then
            return
        end

        if not object:IsA(
            "WeldConstraint"
        ) then
            return
        end

        local grabParts =
            Workspace:
                FindFirstChild(
                    "GrabParts"
                )

        if not grabParts
            or not object:IsDescendantOf(
                grabParts
            )
        then
            return
        end

        local part0 = object.Part0
        local part1 = object.Part1

        local target

        if MH.localCharacterPart(part0) then
            target = part0
        elseif MH.localCharacterPart(part1) then
            target = part1
        end

        if target then
            pcall(function()
                object.Enabled = false
            end)

            pcall(function()
                DestroyGrabLine:
                    FireServer(
                        target
                    )
            end)

            MH.activateGrab()

            if not State.DefenseOwnershipClaimed then
                MH.reclaimLocalOwnership(true)
            end

            MH.fireStruggleLimited(false)
        end

        task.defer(function()
            if not object.Parent
                or not State.Running
                or not Config.AntiGrab
            then
                return
            end

            local deferredPart0 =
                object.Part0

            local deferredPart1 =
                object.Part1

            local deferredTarget

            if MH.localCharacterPart(
                deferredPart0
            ) then
                deferredTarget =
                    deferredPart0
            elseif MH.localCharacterPart(
                deferredPart1
            ) then
                deferredTarget =
                    deferredPart1
            end

            if deferredTarget then
                pcall(function()
                    object.Enabled =
                        false
                end)

                pcall(function()
                    DestroyGrabLine:
                        FireServer(
                            deferredTarget
                        )
                end)

                MH.activateGrab()
                MH.fireStruggleLimited(false)
            end
        end)
    end
)

MH.connect(
    RunService.PreSimulation,

    function(dt)
        if not State.Running then
            return
        end

        local root = State.Root

        if not root or not root.Parent then
            return
        end

        if not State.IsHeld or not State.IsHeld.Parent then
            State.IsHeld = MH.findIsHeld()
        end

        local marker = MH.scanHeadOwner()

        if marker and MH.markerHostile(marker) then
            State.OwnershipLastSeen = os.clock()
        end

        if MH.isHeld() then
            MH.activateGrab()
        end

        if MH.defenseActive() or MH.isHeld() then
            local hostileNow =
                MH.isHeld()
                or MH.ownershipMarkerActive()

            if hostileNow then
                MH.breakIncomingGrab(false)
            end

            MH.guardGrabDisplacement(dt)

            local attacked = MH.sanitizeDefensePhysics()

            if attacked
                and State.DefenseNeedsRagdollReset
            then
                MH.fireRagdollReset()
            end
        else
            if State.DefenseWasActive then
                MH.releaseDefense()
            else
                MH.recordSafePhysics()
            end
        end
    end
)

MH.connect(
    RunService.Heartbeat,

    function()
        if not State.Running then
            return
        end

        local root = State.Root

        if not root or not root.Parent then
            return
        end

        local marker = MH.scanHeadOwner()

        if marker and MH.markerHostile(marker) then
            State.OwnershipLastSeen = os.clock()
        end

        if MH.isHeld() then
            MH.activateGrab()
        end

        if MH.defenseActive() or MH.isHeld() then
            local hostileNow =
                MH.isHeld()
                or MH.ownershipMarkerActive()

            if hostileNow then
                MH.breakIncomingGrab(false)

                if MH.isHeld() then
                    MH.fireStruggleLimited(false)
                end
            end

            local attacked = MH.sanitizeDefensePhysics()

            if attacked
                and State.DefenseNeedsRagdollReset
            then
                MH.fireRagdollReset()
            end
        else
            if State.DefenseWasActive then
                MH.releaseDefense()
            else
                MH.recordSafePhysics()
            end
        end
    end
)

MH.connect(
    RunService.PostSimulation,

    function()
        if not State.Running then
            return
        end

        if MH.defenseActive() or MH.isHeld() then
            MH.sanitizeDefensePhysics()
        else
            if State.DefenseWasActive then
                MH.releaseDefense()
            else
                MH.recordSafePhysics()
            end
        end
    end
)

task.spawn(function()
    while State.Running do
        task.wait(0.025)

        if Config.AntiOwnershipSpam then
            local marker = MH.scanHeadOwner()
            local hostileMarker =
                marker
                and MH.markerHostile(marker)

            if MH.isHeld() then
                if hostileMarker then
                    MH.ownershipPulse()
                else
                    MH.breakIncomingGrab(false)
                    MH.fireStruggleLimited(false)
                end
            elseif hostileMarker then
                if State.DefenseWasActive then
                    MH.releaseDefense()
                end
            elseif State.DefenseWasActive then
                MH.releaseDefense()
            end
        end
    end
end)

task.spawn(function()
    while State.Running do
        task.wait(1)

        if Config.AntiGrab then
            MH.disableInternalFlingHandler()
        end

        MH.refreshCorrectionRemotes()
    end
end)

isKickAllActive = false
kickAllLoopEnabled = false
kickLoopEnabled = false
selectedKickPlayer = nil
playerStatus = {}
currentBlob = nil
seat = nil
kickToggle = nil

function MH.GetMyRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

function MH.GetAllPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local isFriend = false
            pcall(function() isFriend = LocalPlayer:IsFriendsWith(p.UserId) end)
            if not isFriend then table.insert(list, p) end
        end
    end
    return list
end

function MH.PrepareBlobman()
    local toyFolder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    currentBlob = toyFolder and toyFolder:FindFirstChild("CreatureBlobman")

    if not currentBlob then
        local rootPart = MH.GetMyRoot()
        if rootPart then
            local spawnPos = rootPart.CFrame * CFrame.new(0, 0, -5)
            local spawnFunc = ReplicatedStorage:FindFirstChild("MenuToys")
                and ReplicatedStorage.MenuToys:FindFirstChild("SpawnToyRemoteFunction")
            if spawnFunc then
                spawnFunc:InvokeServer("CreatureBlobman", spawnPos, Vector3.new(0, 127, 0))
            end
        end
        task.wait(0.5)
        toyFolder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
        currentBlob = toyFolder and toyFolder:FindFirstChild("CreatureBlobman")
    end

    if currentBlob then
        seat = currentBlob:FindFirstChildOfClass("VehicleSeat")
        if seat and LocalPlayer.Character then
            seat:Sit(LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
        end
    end
    return currentBlob, seat
end

function MH.LookAll()
    if isKickAllActive then return end
    isKickAllActive = true

    local allPlayers = MH.GetAllPlayers()
    if #allPlayers == 0 then
        isKickAllActive = false
        return
    end

    for _, targetPlayer in ipairs(allPlayers) do
        playerStatus[targetPlayer.UserId] = "Targeting"
    end

    local blob, vehicleSeat = MH.PrepareBlobman()
    if not blob or not vehicleSeat then
        isKickAllActive = false
        return
    end
    task.wait(0.3)

    local myRoot = MH.GetMyRoot()
    if not myRoot then
        isKickAllActive = false
        return
    end

    for _, targetPlayer in ipairs(allPlayers) do
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            myRoot.CFrame = targetRoot.CFrame
            task.wait(0.02)
            for i = 1, 5 do
                pcall(function()
                    blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                        blob.LeftDetector, targetRoot, blob.LeftDetector.LeftWeld
                    )
                    blob.BlobmanSeatAndOwnerScript.CreatureRelease:FireServer(blob.LeftDetector.LeftWeld)
                end)
                if i < 5 then task.wait(0.08) end
            end
        end
    end

    myRoot.CFrame = CFrame.new(0, 100, 0)
    task.wait(0.1)

    for _, part in ipairs(blob:GetDescendants()) do
        if part:IsA("BasePart") then pcall(function() part.Anchored = true end) end
    end
    task.wait(0.1)

    local radius = 15
    for i, targetPlayer in ipairs(allPlayers) do
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local angle = math.rad((i - 1) * (360 / #allPlayers))
            local x = radius * math.cos(angle)
            local z = radius * math.sin(angle)
            targetRoot.CFrame = CFrame.new(x, 110, z)
        end
    end
    task.wait(0.1)

    for _ = 1, 2 do
        for _, targetPlayer in ipairs(allPlayers) do
            local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                task.spawn(function()
                    pcall(function()
                        SetNetworkOwner:FireServer(targetRoot, CFrame.new(targetRoot.Position))
                        DestroyGrabLine:FireServer(targetRoot)
                    end)
                end)
            end
        end
        task.wait(0.1)
    end

    task.wait(0.3)

    for _, targetPlayer in ipairs(allPlayers) do
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            task.spawn(function()
                pcall(function()
                    blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                        blob.LeftDetector, targetRoot, blob.LeftDetector.LeftWeld
                    )
                    blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                        blob.RightDetector, targetRoot, blob.RightDetector.RightWeld
                    )
                end)
            end)
        end
    end

    task.wait(0.1)
    myRoot.CFrame = CFrame.new(0, -50000, 0)

    for _, part in ipairs(blob:GetDescendants()) do
        if part:IsA("BasePart") then pcall(function() part.Anchored = false end) end
    end

    task.wait(1)
    isKickAllActive = false
end

function MH.StartSingleKickLoop()
    if not selectedKickPlayer then return end

    local blob, vehicleSeat = MH.PrepareBlobman()
    if not blob or not vehicleSeat then
        pcall(function() kickToggle:SetValue(false) end)
        return
    end

    task.spawn(function()
        local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
        local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")

        local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
        local CD = scriptObj and scriptObj:FindFirstChild("CreatureDrop")

        local R_Det = blob:FindFirstChild("RightDetector")
        local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))

        local SavedPos = blobRoot and blobRoot.CFrame

        local tChar = selectedKickPlayer.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")

        if tRoot and blobRoot and SavedPos then
            local bringStart = tick()
            while tick() - bringStart < 0.35 do
                if not kickLoopEnabled then break end
                blobRoot.CFrame = tRoot.CFrame
                blobRoot.Velocity = Vector3.zero
                pcall(function()
                    if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                    CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                    SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                end)
                RunService.Heartbeat:Wait()
            end
            blobRoot.CFrame = SavedPos
            blobRoot.Velocity = Vector3.zero
            task.wait(0.05)
        end

        local packetTimer = 0

        while kickLoopEnabled and State.Running do
            if not selectedKickPlayer or not selectedKickPlayer.Parent or not selectedKickPlayer.Character then break end

            tChar = selectedKickPlayer.Character
            tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar and tChar:FindFirstChild("Humanoid")

            if tRoot and tHum and tHum.Health > 0 and blobRoot and SavedPos then
                blobRoot.CFrame = SavedPos
                blobRoot.Velocity = Vector3.zero
                local lockPos = SavedPos * CFrame.new(0, 23, 0)
                tRoot.CFrame = lockPos
                tRoot.Velocity = Vector3.zero
                tRoot.RotVelocity = Vector3.zero

                if tick() - packetTimer > 0.05 then
                    packetTimer = tick()
                    pcall(function()
                        tHum.PlatformStand = true
                        tHum.Sit = true
                        SetNetworkOwner:FireServer(tRoot, lockPos)
                        if R_Det then
                            local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld")
                            if weld then CD:FireServer(weld) end
                        end
                        DestroyGrabLine:FireServer(tRoot)
                        if R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                        CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                    end)
                end
            else
                if blobRoot and SavedPos then
                    blobRoot.CFrame = SavedPos
                    blobRoot.Velocity = Vector3.zero
                end
            end

            if not kickLoopEnabled then break end
            RunService.Heartbeat:Wait()
        end

        kickLoopEnabled = false
        pcall(function() kickToggle:SetValue(false) end)
        if blobRoot and SavedPos then
            blobRoot.CFrame = SavedPos
            blobRoot.Velocity = Vector3.zero
        end
    end)
end

function State.V14.getUpdateLineColorsEvent()
    local dataEvents = ReplicatedStorage:FindFirstChild("DataEvents")
    return dataEvents and dataEvents:FindFirstChild("UpdateLineColorsEvent")
end

function State.V14.applyLineColor()
    local event = State.V14.getUpdateLineColorsEvent()
    if not event then
        State.V14.warnFeatureOnce("LineColor", "UpdateLineColorsEvent is unavailable.")
        return false
    end

    local selectedColor = Color3.fromRGB(Config.LineR, Config.LineG, Config.LineB)
    local payload = { ColorSequence.new(selectedColor) }
    for index = 2, 10 do
        payload[index] = selectedColor
    end

    pcall(function()
        event:FireServer(table.unpack(payload))
    end)
    return true
end

function State.V14.setInvisibleLine(enabled)
    Config.InvisibleLine = enabled
    State.V14.disconnectFeatureBucket("InvisibleLine")
    if not enabled then
        return
    end

    State.V14.trackFeatureConnection("InvisibleLine", Workspace.ChildAdded:Connect(function(child)
        if not Config.InvisibleLine or not State.Running then
            return
        end
        if child.Name == "GrabParts" then
            task.defer(function()
                if Config.InvisibleLine and child.Parent then
                    pcall(function()
                        CreateGrabLine:FireServer()
                    end)
                end
            end)
        end
    end))
end

function State.V14.stopCrazyLine()
    Config.CrazyLine = false
    State.V14.cancelWorker("CrazyLine")
end

function State.V14.startCrazyLine()
    State.V14.stopCrazyLine()
    Config.CrazyLine = true
    local token = State.V14.newWorkerToken("CrazyLine")
    task.spawn(function()
        local effectCFrame = CFrame.new(0.12640380859375, 0.9606337547302246, -0.5000009536743164, 0.9985212683677673, 0, -0.05436277016997337, -0.0000000064805472, 1, -0.000000119033011, 0.05436277016997337, 0.0000000596046448, 0.9985212683677673)
        while State.V14.workerTokenAlive("CrazyLine", token) and Config.CrazyLine do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local character = player.Character
                    local target = character and (character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("HumanoidRootPart"))
                    if target then
                        pcall(function()
                            CreateGrabLine:FireServer(target, effectCFrame)
                        end)
                    end
                end
                if not State.V14.workerTokenAlive("CrazyLine", token) or not Config.CrazyLine then
                    break
                end
                task.wait()
            end
            task.wait()
        end
        if State.FeatureWorkerTokens.CrazyLine == token then
            Config.CrazyLine = false
        end
    end)
end

function State.V14.stopLagServer()
	Config.LagServer = false

	local workerCount = 10000

	for workerId = 1, workerCount do
		State.V14.cancelWorker("LagServer_" .. workerId)
	end

	if State.V14.LagServerActiveTargets then
		for _, activeTargets in pairs(State.V14.LagServerActiveTargets) do
			for part in pairs(activeTargets) do
				if part and part.Parent then
					pcall(function()
						DestroyGrabLine:FireServer(part)
					end)
				end
			end

			table.clear(activeTargets)
		end

		table.clear(State.V14.LagServerActiveTargets)
	end

	State.V14.LagServerActiveTargets = nil
end

function State.V14.startLagServer()
	State.V14.stopLagServer()

	Config.LagServer = true

	local WORKER_COUNT = 10000
	local RANDOM_OFFSET = 1.5

	State.V14.LagServerActiveTargets = {}

	local function getTargetPart(player)
		if player == LocalPlayer then
			return nil
		end

		local character = player.Character

		if not character then
			return nil
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.Health <= 0 then
			return nil
		end

		return character:FindFirstChild("HumanoidRootPart")
			or character:FindFirstChild("UpperTorso")
			or character:FindFirstChild("Torso")
			or character:FindFirstChild("Head")
	end

	local function randomOffset()
		return CFrame.new(
			math.random(-100, 100) / 100 * RANDOM_OFFSET,
			math.random(-100, 100) / 100 * RANDOM_OFFSET,
			math.random(-100, 100) / 100 * RANDOM_OFFSET
		)
	end

	local function collectTargets()
		local targets = {}

		for _, player in ipairs(Players:GetPlayers()) do
			local part = getTargetPart(player)

			if part then
				targets[#targets + 1] = part
			end
		end

		return targets
	end

	for workerId = 1, WORKER_COUNT do
		local workerName = "LagServer_" .. workerId
		local token = State.V14.newWorkerToken(workerName)

		local ActiveTargets = {}
		State.V14.LagServerActiveTargets[workerId] = ActiveTargets

		local function alive()
			return Config.LagServer
				and State.V14.workerTokenAlive(workerName, token)
		end

		local function createLine(part)
			if not alive() then
				return false
			end

			if not part or not part.Parent then
				return false
			end

			local success = pcall(function()
				CreateGrabLine:FireServer(part, randomOffset())
			end)

			if success then
				ActiveTargets[part] = true
			end

			return success
		end

		local function destroyLine(part)
			if not part then
				return
			end

			if part.Parent then
				pcall(function()
					DestroyGrabLine:FireServer(part)
				end)
			end

			ActiveTargets[part] = nil
		end

		local function clearAll()
			local targets = {}

			for part in pairs(ActiveTargets) do
				targets[#targets + 1] = part
			end

			for _, part in ipairs(targets) do
				destroyLine(part)
			end
		end

		task.spawn(function()
			while alive() do
				local targets = collectTargets()

				if #targets > 0 then
					local cycleTargets = {}

					for _, part in ipairs(targets) do
						if not alive() then
							break
						end

						if part and part.Parent then
							if createLine(part) then
								cycleTargets[#cycleTargets + 1] = part
							end
						end

						task.wait(Config.LagTargetDelay or 0.04)
					end

					local lifetime = Config.LagLineLifetime or 2

					task.delay(lifetime, function()
						for _, part in ipairs(cycleTargets) do
							if ActiveTargets[part] then
								destroyLine(part)
							end
						end
					end)
				end

				task.wait(Config.LagCycleDelay or 0.35)
			end

			clearAll()

			if State.V14.LagServerActiveTargets then
				State.V14.LagServerActiveTargets[workerId] = nil
			end
		end)
	end
end

function MH.mouseDetector(
    actionName,
    inputState,
    inputObject
)
    if inputState
        ~= Enum.UserInputState.Begin
    then
        return Enum.ContextActionResult.Pass
    end

    if inputObject.UserInputType
        == Enum.UserInputType.MouseButton1
    then
        State.LastMouseButton =
            1

        State.LastMouseTime =
            os.clock()

    elseif inputObject.UserInputType
        == Enum.UserInputType.MouseButton2
    then
        State.LastMouseButton =
            2

        State.LastMouseTime =
            os.clock()
    end

    return Enum.ContextActionResult.Pass
end

ContextActionService:
    BindActionAtPriority(
        "MangaHub_MouseDetector",
        MH.mouseDetector,
        false,
        Enum.ContextActionPriority.High.Value
            + 1000,
        Enum.UserInputType.MouseButton1,
        Enum.UserInputType.MouseButton2
    )

function MH.getReleaseButton()
    if UserInputService:
        IsMouseButtonPressed(
            Enum.UserInputType.MouseButton2
        )
    then
        return 2
    end

    if UserInputService:
        IsMouseButtonPressed(
            Enum.UserInputType.MouseButton1
        )
    then
        return 1
    end

    if os.clock()
        - State.LastMouseTime
        <= Config.MouseMemory
    then
        return State.LastMouseButton
    end

    return 0
end

function MH.throwObject(object)
    if State.Throwing
        or not State.Running
        or not Config.ThrowEnabled
    then
        return
    end

    local root =
        MH.getAssemblyRoot(
            object
        )
        or MH.getAssemblyRoot(
            State.OwnerObject
        )
        or MH.getAssemblyRoot(
            State.GrabbedObject
        )

    if not root
        or root.Anchored
    then
        return
    end

    local camera =
        Workspace.CurrentCamera

    if not camera then
        return
    end

    State.Throwing =
        true

    local speed =
        math.clamp(
            Config.ThrowForce,
            Config.ThrowMin,
            Config.ThrowMax
        )

    local desiredVelocity =
        camera.CFrame.LookVector
        * speed

    RunService.Heartbeat:
        Wait()

    if not root.Parent then
        State.Throwing =
            false

        return
    end

    local impulse =
        (
            desiredVelocity
            - root.AssemblyLinearVelocity
        )
        * root.AssemblyMass

    pcall(function()
        root:ApplyImpulse(
            impulse
        )
    end)

    root.AssemblyLinearVelocity =
        desiredVelocity

    for _ = 1,
        Config.ThrowFrames
    do
        RunService.Heartbeat:
            Wait()

        if not State.Running
            or not root.Parent
        then
            break
        end

        local velocity =
            root.AssemblyLinearVelocity

        if velocity.Magnitude
            < speed * 0.75
        then
            local correction =
                (
                    desiredVelocity
                    - velocity
                )
                * root.AssemblyMass

            pcall(function()
                root:ApplyImpulse(
                    correction
                )
            end)

            root.AssemblyLinearVelocity =
                desiredVelocity
        end
    end

    State.Throwing =
        false
end

MobileThrowController = {
    Running = true
}

function MH.mobileThrowHookFunction()
    if typeof(hookfunction)
        == "function"
    then
        return hookfunction
    end

    if typeof(hookfunc)
        == "function"
    then
        return hookfunc
    end

    return nil
end

function MH.clearMobileThrowBinding()
    local hook =
        MH.mobileThrowHookFunction()

    if hook
        and State.MobileThrowFunction
        and State.MobileThrowOriginal
    then
        pcall(
            hook,
            State.MobileThrowFunction,
            State.MobileThrowOriginal
        )
    end

    State.MobileThrowBoundScript = nil
    State.MobileThrowFunction = nil
    State.MobileThrowOriginal = nil
end

function MH.bindMobileThrowFunction()
    local grabbingScript =
        MH.lineCurrentGrabScript()

    if not grabbingScript then
        return false
    end

    if State.MobileThrowBoundScript
            == grabbingScript
        and State.MobileThrowFunction
        and State.MobileThrowOriginal
    then
        return true
    end

    MH.clearMobileThrowBinding()

    local hook =
        MH.mobileThrowHookFunction()

    if not hook then
        return false
    end

    for _, fn in ipairs(
        MH.lineFunctions()
    ) do
        if MH.lineFunctionScript(fn)
            == grabbingScript
        then
            local info =
                MH.lineFunctionInfo(fn)

            local name =
                info
                and tostring(
                    info.name
                        or ""
                )
                or ""

            if name == "throw" then
                local original

                local wrapper =
                    function(...)
                        if MobileThrowController.Running
                            and State.Running
                            and Config.ThrowEnabled
                            and UserInputService.TouchEnabled
                        then
                            State.MobileThrowIntentUntil =
                                os.clock()
                                + 1.25
                        end

                        if original then
                            return original(...)
                        end
                    end

                if typeof(newcclosure)
                    == "function"
                then
                    wrapper =
                        newcclosure(
                            wrapper
                        )
                end

                local ok, result =
                    pcall(
                        hook,
                        fn,
                        wrapper
                    )

                if ok
                    and type(result)
                        == "function"
                then
                    original = result

                    State.MobileThrowBoundScript =
                        grabbingScript
                    State.MobileThrowFunction = fn
                    State.MobileThrowOriginal = result

                    return true
                end
            end
        end
    end

    return false
end

function MH.mobileThrowIntentActive()
    return UserInputService.TouchEnabled
        and os.clock()
            <= State.MobileThrowIntentUntil
end

function MobileThrowController.Stop()
    MobileThrowController.Running = false
    State.MobileThrowIntentUntil = 0

    MH.clearMobileThrowBinding()

    if ENV.MangaMobileThrowController
        == MobileThrowController
    then
        ENV.MangaMobileThrowController = nil
    end
end

ENV.MangaMobileThrowController =
    MobileThrowController

task.spawn(function()
    while State.Running
        and MobileThrowController.Running
    do
        if UserInputService.TouchEnabled then
            local currentScript =
                MH.lineCurrentGrabScript()

            if State.MobileThrowBoundScript
                    ~= currentScript
                or not State.MobileThrowFunction
            then
                MH.bindMobileThrowFunction()
            end
        end

        task.wait(0.75)
    end
end)

State.V14.CustomLineTab =
    Window:CreateTab(
        "Custom Line",
        "🧵"
    )

State.V14.CustomLineExtendSection = State.V14.CustomLineTab:CreateSection("Line Extender")
State.V14.CustomLineLaunchSection = State.V14.CustomLineTab:CreateSection("Launch Controls")
State.V14.CustomLineColorSection = State.V14.CustomLineTab:CreateSection("Change your entire line color")
State.V14.CustomLineEffectsSection = State.V14.CustomLineTab:CreateSection("Line Effects")
State.V14.CustomLineStressSection = State.V14.CustomLineTab:CreateSection("Stress Server")
State.V14.CustomLineStatus = State.V14.CustomLineExtendSection:CreateLabel("0 = Normal | 1-27 = Extended | 28 = Infinite")

function MH.updateLineStatus()
    local level = math.clamp(
        math.floor(Config.LineLevel + 0.5),
        0,
        Config.LineInfiniteLevel
    )

    if not Config.LineEnabled then
        State.V14.CustomLineStatus:SetText("Disabled | 0 = Normal | 28 = Infinite")
    elseif level <= 0 then
        State.V14.CustomLineStatus:SetText("Enabled | Normal limit")
    elseif level >= Config.LineInfiniteLevel then
        State.V14.CustomLineStatus:SetText("Enabled | Infinite")
    else
        State.V14.CustomLineStatus:SetText(
            "Enabled | Level " .. tostring(level) .. " | Max x" .. tostring(level + 1)
        )
    end
end

State.V14.CustomLineExtendSection:CreateToggle({
    Text = "Line Extension",
    Default = Config.LineEnabled,
    Flag = "CustomLineExtension",
    Callback = function(value)
        Config.LineEnabled = value
        State.LineFailureNotified = false
        State.LineNextRescan = 0
        if value then
            MH.applyLineReach()
        else
            MH.restoreLineReach()
        end
        MH.updateLineStatus()
    end
})

State.V14.CustomLineExtendSection:CreateSlider({
    Text = "Line Reach (28 = Infinite)",
    Min = 0,
    Max = Config.LineInfiniteLevel,
    Default = Config.LineLevel,
    Decimals = 0,
    Flag = "CustomLineReach",
    Callback = function(value)
        Config.LineLevel = math.clamp(math.floor(value + 0.5), 0, Config.LineInfiniteLevel)
        if Config.LineEnabled then
            MH.applyLineReach()
        end
        MH.updateLineStatus()
    end
})

State.V14.CustomLineLaunchSection:CreateToggle({
    Text = "Launch",
    Default = Config.ThrowEnabled,
    Flag = "ThrowEnabled",
    Callback = function(value)
        Config.ThrowEnabled = value

        if not value then
            State.MobileThrowIntentUntil = 0
            State.Throwing = false
        end
    end
})

State.V14.CustomLineLaunchSection:CreateSlider({
    Text = "Força",

    Min = Config.ThrowMin,
    Max = Config.ThrowMax,
    Default = Config.ThrowForce,

    Decimals = 0,

    Flag = "ThrowForce",

    Callback = function(value)
        Config.ThrowForce =
            math.clamp(
                math.floor(
                    value + 0.5
                ),
                Config.ThrowMin,
                Config.ThrowMax
            )
    end
})

for _, spec in ipairs({
    { "Line R", "LineR" },
    { "Line G", "LineG" },
    { "Line B", "LineB" }
}) do
    State.V14.CustomLineColorSection:CreateSlider({
        Text = spec[1],
        Min = 0,
        Max = 255,
        Default = Config[spec[2]],
        Decimals = 0,
        Flag = spec[2],
        Callback = function(value)
            Config[spec[2]] = math.floor(value + 0.5)
        end
    })
end

State.V14.CustomLineColorSection:CreateButton({
    Text = "Apply Colors",
    Callback = function()
        State.FeatureWarnings.LineColor = nil
        State.V14.applyLineColor()
    end
})

State.V14.CustomLineEffectsSection:CreateToggle({
    Text = "Invisible Line",
    Default = false,
    Flag = "InvisibleLine",
    Callback = State.V14.setInvisibleLine
})

State.V14.CustomLineEffectsSection:CreateToggle({
    Text = "Crazy Line",
    Default = false,
    Flag = "CrazyLine",
    Callback = function(value)
        if value then
            State.V14.startCrazyLine()
        else
            State.V14.stopCrazyLine()
        end
    end
})

State.V14.CustomLineStressSection:CreateToggle({
    Text = "Lag Server",
    Default = false,
    Flag = "LagServer",
    Callback = function(value)
        if value then
            State.V14.startLagServer()
        else
            State.V14.stopLagServer()
        end
    end
})

State.V14.CustomLineStressSection:CreateSlider({
    Text = "tempo de vida da linha",
    Min = 0.001,
    Max = 10,
    Default = Config.CrazyLineLifetime or 2,
    Decimals = 2,
    Flag = "CrazyLineLifetime",
    Callback = function(value)
        Config.CrazyLineLifetime = value
    end
})

State.V14.CustomLineStressSection:CreateSlider({
    Text = "Delay do novo ciclo",
    Min = 0.001,
    Max = 5,
    Default = Config.CrazyLineCycleDelay or 0.35,
    Decimals = 2,
    Flag = "CrazyLineCycleDelay",
    Callback = function(value)
        Config.CrazyLineCycleDelay = value
    end
})

State.V14.CustomLineStressSection:CreateSlider({
    Text = "delay de escolher novo jogador",
    Min = 0.001,
    Max = 1,
    Default = Config.CrazyLineTargetDelay or 0.04,
    Decimals = 2,
    Flag = "CrazyLineTargetDelay",
    Callback = function(value)
        Config.CrazyLineTargetDelay = value
    end
})

State.V14.CombatTab =
    Window:CreateTab(
        "Combat",
        "⚔️"
    )

State.V14.CombatOthersSection = State.V14.CombatTab:CreateSection("Others")
State.V14.CombatPerspectiveSection = State.V14.CombatTab:CreateSection("Perspective")

State.V14.CombatOthersSection:CreateToggle({
    Text = "Kill Grab",
    Default = Config.KillGrab,
    Flag = "CombatKillGrab",
    Callback = function(value)
        Config.KillGrab = value
        State.V14.resetKillGrabState()
    end
})

State.V14.CombatOthersSection:CreateToggle({
    Text = "Poison Grab",
    Default = false,
    Flag = "CombatPoisonGrab",
    Callback = function(value)
        Config.PoisonGrab = value
        State.FeatureWarnings.PoisonGrab = nil
    end
})

State.V14.CombatOthersSection:CreateToggle({
    Text = "Burn Grab",
    Default = false,
    Flag = "CombatBurnGrab",
    Callback = function(value)
        Config.BurnGrab = value
        State.FeatureWarnings.BurnGrab = nil
    end
})

State.V14.CombatOthersSection:CreateToggle({
    Text = "Radioactive Grab",
    Default = false,
    Flag = "CombatRadioactiveGrab",
    Callback = function(value)
        Config.RadioactiveGrab = value
        State.FeatureWarnings.RadioactiveGrab = nil
    end
})

State.V14.CombatOthersSection:CreateToggle({
    Text = "Massless Grab",
    Default = Config.MasslessGrab,
    Flag = "CombatMasslessGrab",
    Callback = function(value)
        Config.MasslessGrab = value
        if not value then
            MH.restoreGrabMassless()
        end
    end
})

State.V14.CombatOthersSection:CreateToggle({
    Text = "Noclip Grab",
    Default = Config.NoclipGrab,
    Flag = "CombatNoclipGrab",
    Callback = function(value)
        Config.NoclipGrab = value
        if not value then
            MH.restoreGrabCollisions()
        end
    end
})

State.V14.CombatPerspectiveSection:CreateToggle({
    Text = "Perspective Grab",
    Default = false,
    Flag = "PerspectiveGrab",
    Callback = function(value)
        Config.PerspectiveGrab = value
        if not value then
            State.V14.stopPerspectiveGrab()
        end
    end
})

State.V14.CombatPerspectiveSection:CreateSlider({
    Text = "Perspective Speed",
    Min = 50,
    Max = 150,
    Default = Config.PerspectiveSpeed,
    Decimals = 0,
    Flag = "PerspectiveSpeed",
    Callback = function(value)
        Config.PerspectiveSpeed = value
    end
})

State.V14.InvincibilityTab =
    Window:CreateTab(
        "Invincibility",
        "🛡️"
    )

State.V14.InvulnerabilitySection = State.V14.InvincibilityTab:CreateSection("Invulnerability")
State.V14.CounterAttackSection = State.V14.InvincibilityTab:CreateSection("Counter-Attack")

State.V14.InvulnerabilitySection:CreateToggle({
    Text = "Anti-Grab",
    Default = Config.AntiGrab,
    Flag = "InvAntiGrab",
    Callback = function(value)
        Config.AntiGrab = value

        if value then
            State.LastStruggle = -math.huge
            State.LastBurst = -math.huge
            State.LastDefenseBreak = -math.huge
            State.LastDefenseReclaim = -math.huge
            State.IsHeld = MH.findIsHeld()

            MH.disableInternalFlingHandler()

            if State.Root and State.Root.Parent then
                MH.recordSafePhysics()
            end

            if MH.isHeld() then
                MH.grabPulse()
            end
        else
            MH.releaseDefense()
        end
    end
})

State.V14.InvulnerabilitySection:CreateToggle({
    Text = "Ownership Guard",
    Default = Config.AntiOwnershipSpam,
    Flag = "InvOwnershipGuard",
    Callback = function(value)
        Config.AntiOwnershipSpam = value

        if value then
            local marker = MH.scanHeadOwner()

            if marker and MH.markerHostile(marker) then
                MH.ownershipPulse()
            end
        else
            State.OwnershipLastSeen = -math.huge
            State.LastOwnershipPulse = 0

            if not MH.isHeld() then
                MH.releaseDefense()
            else
                MH.recordSafePhysics()
            end
        end
    end
})

State.V14.InvulnerabilitySection:CreateToggle({
    Text = "Anti-Burn",
    Default = false,
    Flag = "AntiBurn",
    Callback = function(value)
        Config.AntiBurn = value
        State.FeatureWarnings.AntiBurn = nil
    end
})

State.V14.InvulnerabilitySection:CreateToggle({
    Text = "Anti-Explosion",
    Default = false,
    Flag = "AntiExplosion",
    Callback = function(value)
        Config.AntiExplosion = value
        if not value then
            State.V14.pulseAntiExplosion()
        end
    end
})

State.V14.CounterAttackSection:CreateToggle({
    Text = "Auto-Attacker",
    Default = false,
    Flag = "AutoAttacker",
    Callback = function(value)
        Config.AutoAttacker = value
    end
})

State.V14.CounterAttackSection:CreateDropdown({
    Text = "Counter Mode",
    List = { "Repulsion", "Freeze", "Death", "Kick" },
    Default = Config.CounterMode,
    Flag = "CounterMode",
    Callback = function(value)
        Config.CounterMode = value
    end
})

function MH.buildPlayerList()
    local list = {}
    local map = {}

    local players =
        Players:GetPlayers()

    table.sort(
        players,

        function(a, b)
            return string.lower(
                a.Name
            )
                < string.lower(
                    b.Name
                )
        end
    )

    for _, player in ipairs(
        players
    ) do
        if player
            ~= LocalPlayer
        then
            local label =
                string.format(
                    "%s (@%s)",
                    player.DisplayName,
                    player.Name
                )

            map[label] =
                player

            table.insert(
                list,
                label
            )
        end
    end

    if #list == 0 then
        list[1] =
            "Nenhum jogador"
    end

    return list,
        map
end

function MH.getMountedBlobman()
    local humanoid =
        State.Humanoid

    if not humanoid then
        return nil
    end

    local seat =
        humanoid.SeatPart

    if seat then
        local current =
            seat

        while current
            and current ~= Workspace
        do
            if current:IsA(
                "Model"
            )
                and current.Name
                    == "CreatureBlobman"
            then
                return current
            end

            current =
                current.Parent
        end
    end

    for _, object in ipairs(
        Workspace:GetDescendants()
    ) do
        if object:IsA(
            "Model"
        )
            and object.Name
                == "CreatureBlobman"
        then
            local vehicleSeat =
                object:
                    FindFirstChildWhichIsA(
                        "VehicleSeat",
                        true
                    )

            if vehicleSeat
                and vehicleSeat.Occupant
                    == humanoid
            then
                return object
            end
        end
    end

    return nil
end

function State.V14.blobmanTargetAllowed(player)
    if not player or player == LocalPlayer or player.Parent ~= Players then
        return false
    end
    if Config.BlobWhitelistFriends then
        local ok, isFriend = pcall(function()
            return LocalPlayer:IsFriendsWith(player.UserId)
        end)
        if ok and isFriend then
            return false
        end
    end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return humanoid ~= nil and root ~= nil and humanoid.Health > 0
end

function State.V14.blobmanGrabPlayer(player, mode)
    if not State.V14.blobmanTargetAllowed(player) then
        return false
    end

    local blob = MH.getMountedBlobman()
    if not blob then
        return false
    end

    local character = player.Character
    local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
    local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
    local CreatureGrab = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
    local detector = blob:FindFirstChild("LeftDetector") or blob:FindFirstChild("RightDetector")
    local weld = detector and (detector:FindFirstChild("LeftWeld") or detector:FindFirstChild("RightWeld") or detector:FindFirstChildWhichIsA("Weld"))

    if not targetRoot or not CreatureGrab or not detector then
        return false
    end

    local ok = pcall(function()
        CreatureGrab:FireServer(detector, targetRoot, weld)
    end)

    if not ok then
        return false
    end

    if mode == "Kick" then
        task.defer(function()
            RunService.Heartbeat:Wait()
            if targetRoot.Parent and State.V14.isPlayerLocallyOwned(player) then
                pcall(function()
                    targetRoot.AssemblyLinearVelocity = Vector3.new(0, 1000000, 0)
                    DestroyGrabLine:FireServer(targetRoot)
                end)
            end
        end)
    end

    return true
end

function State.V14.startBlobmanLoopKick()
    local token = State.V14.newWorkerToken("BlobmanLoopKick")
    Config.BlobLoopKick = true
    task.spawn(function()
        local originalBlob = MH.getMountedBlobman()
        while State.V14.workerTokenAlive("BlobmanLoopKick", token) and Config.BlobLoopKick do
            local player = State.BlobSelectedPlayer
            local blob = MH.getMountedBlobman()
            if not originalBlob or blob ~= originalBlob or not State.V14.blobmanTargetAllowed(player) then
                break
            end
            State.V14.blobmanGrabPlayer(player, "Kick")
            task.wait(0.2)
        end
        if State.FeatureWorkerTokens.BlobmanLoopKick == token then
            Config.BlobLoopKick = false
        end
    end)
end

function State.V14.stopBlobmanLoopKick()
    Config.BlobLoopKick = false
    State.V14.cancelWorker("BlobmanLoopKick")
end

function State.V14.blobmanGrabAllOnce()
    local blob = MH.getMountedBlobman()
    if not blob then
        return false
    end

    local acted = false
    for _, player in ipairs(Players:GetPlayers()) do
        if State.V14.blobmanTargetAllowed(player) then
            acted = State.V14.blobmanGrabPlayer(player, "Grab") or acted
            task.wait()
        end
    end
    return acted
end

function State.V14.startBlobmanDestroyServer()
    local token = State.V14.newWorkerToken("BlobmanDestroyServer")
    Config.BlobDestroyServer = true
    task.spawn(function()
        local originalBlob = MH.getMountedBlobman()
        while State.V14.workerTokenAlive("BlobmanDestroyServer", token) and Config.BlobDestroyServer do
            local blob = MH.getMountedBlobman()
            if not originalBlob or blob ~= originalBlob then
                break
            end
            State.V14.blobmanGrabAllOnce()
            task.wait(0.2)
        end
        if State.FeatureWorkerTokens.BlobmanDestroyServer == token then
            Config.BlobDestroyServer = false
        end
    end)
end

function State.V14.stopBlobmanDestroyServer()
    Config.BlobDestroyServer = false
    State.V14.cancelWorker("BlobmanDestroyServer")
end

function MH.getSelectedBlobTarget()
    local player =
        State.BlobSelectedPlayer

    if not player
        or player.Parent
            ~= Players
    then
        Window:Notify({
            Title = "Blobman",
            Text = "Selecione um player.",
            Duration = 2
        })

        return nil
    end

    local character =
        player.Character

    local root =
        character
        and character:
            FindFirstChild(
                "HumanoidRootPart"
            )

    local humanoid =
        character
        and character:
            FindFirstChildOfClass(
                "Humanoid"
            )

    if not root
        or not humanoid
        or humanoid.Health <= 0
    then
        Window:Notify({
            Title = "Blobman",
            Text = "Player indisponível.",
            Duration = 2
        })

        return nil
    end

    return player,
        character,
        root,
        humanoid
end

function MH.jumpFromBlob()
    local humanoid =
        State.Humanoid

    if not humanoid then
        return
    end

    humanoid.Jump =
        true

    pcall(function()
        humanoid:
            ChangeState(
                Enum.HumanoidStateType.Jumping
            )
    end)
end

function MH.blobBringPhase(blob, tRoot)
    local blobRoot =
        blob:FindFirstChild(
            "HumanoidRootPart"
        )
        or blob.PrimaryPart

    local scriptObj =
        blob:FindFirstChild(
            "BlobmanSeatAndOwnerScript"
        )

    local CG =
        scriptObj
        and scriptObj:
            FindFirstChild(
                "CreatureGrab"
            )

    local R_Det =
        blob:FindFirstChild(
            "RightDetector"
        )

    local R_Weld =
        R_Det
        and (
            R_Det:FindFirstChild(
                "RightWeld"
            )
            or R_Det:FindFirstChildWhichIsA(
                "Weld"
            )
        )

    if not blobRoot
        or not CG
    then
        return nil,
            nil
    end

    local SavedPos =
        blobRoot.CFrame

    local bringStart =
        tick()

    while tick() - bringStart < 0.35 do
        blobRoot.CFrame =
            tRoot.CFrame

        blobRoot.Velocity =
            Vector3.zero

        pcall(function()
            if CG and R_Det then
                CG:FireServer(
                    R_Det,
                    tRoot,
                    R_Weld
                )
            end

            CreateGrabLine:FireServer(
                tRoot,
                Vector3.zero,
                tRoot.Position,
                false
            )

            SetNetworkOwner:FireServer(
                tRoot,
                blobRoot.CFrame
            )
        end)

        RunService.Heartbeat:
            Wait()
    end

    return blobRoot,
        SavedPos
end

function MH.bringBlobPlayer()
    local player,
        character,
        targetRoot,
        targetHumanoid =
        MH.getSelectedBlobTarget()

    if not player then
        return
    end

    local blob =
        MH.getMountedBlobman()

    if not blob then
        Window:Notify({
            Title = "Blobman",
            Text = "Sente no Blobman primeiro.",
            Duration = 2
        })

        return
    end

    task.spawn(function()
        local blobRoot,
            SavedPos =
            MH.blobBringPhase(
                blob,
                targetRoot
            )

        if not blobRoot
            or not SavedPos
        then
            Window:Notify({
                Title = "Blobman",
                Text = "Bring falhou.",
                Duration = 2
            })

            return
        end

        blobRoot.CFrame =
            SavedPos

        blobRoot.Velocity =
            Vector3.zero

        targetRoot.CFrame =
            SavedPos
            * CFrame.new(
                0,
                3,
                0
            )

        targetRoot.Velocity =
            Vector3.zero

        local scriptObj =
            blob:FindFirstChild(
                "BlobmanSeatAndOwnerScript"
            )

        local CG =
            scriptObj
            and scriptObj:
                FindFirstChild(
                    "CreatureGrab"
                )

        local R_Det =
            blob:FindFirstChild(
                "RightDetector"
            )

        local R_Weld =
            R_Det
            and (
                R_Det:FindFirstChild(
                    "RightWeld"
                )
                or R_Det:FindFirstChildWhichIsA(
                    "Weld"
                )
            )

        local stickEnd =
            tick()
            + Config.BlobBringStickTime

        while tick() < stickEnd do
            if not targetRoot.Parent then
                break
            end

            pcall(function()
                if CG and R_Det then
                    CG:FireServer(
                        R_Det,
                        targetRoot,
                        R_Weld
                    )
                end

                SetNetworkOwner:FireServer(
                    targetRoot,
                    SavedPos
                )
            end)

            RunService.Heartbeat:
                Wait()
        end

        Window:Notify({
            Title = "Blobman",
            Text = "Bring: "
                .. player.Name,
            Duration = 2
        })
    end)
end

function MH.lockBlobPlayer()
    local player,
        character,
        targetRoot,
        targetHumanoid =
        MH.getSelectedBlobTarget()

    if not player then
        return
    end

    local blob =
        MH.getMountedBlobman()

    if not blob then
        Window:Notify({
            Title = "Blobman",
            Text = "Sente no Blobman primeiro.",
            Duration = 2
        })

        return
    end

    task.spawn(function()
        local blobRoot,
            SavedPos =
            MH.blobBringPhase(
                blob,
                targetRoot
            )

        if not blobRoot
            or not SavedPos
        then
            Window:Notify({
                Title = "Blobman",
                Text = "Lock falhou.",
                Duration = 2
            })

            return
        end

        blobRoot.CFrame =
            SavedPos

        blobRoot.Velocity =
            Vector3.zero

        task.wait(0.05)

        local scriptObj =
            blob:FindFirstChild(
                "BlobmanSeatAndOwnerScript"
            )

        local CG =
            scriptObj
            and scriptObj:
                FindFirstChild(
                    "CreatureGrab"
                )

        local CD =
            scriptObj
            and scriptObj:
                FindFirstChild(
                    "CreatureDrop"
                )

        local R_Det =
            blob:FindFirstChild(
                "RightDetector"
            )

        local L_Det =
            blob:FindFirstChild(
                "LeftDetector"
            )

        local R_Weld =
            R_Det
            and (
                R_Det:FindFirstChild(
                    "RightWeld"
                )
                or R_Det:FindFirstChildWhichIsA(
                    "Weld"
                )
            )

        local L_Weld =
            L_Det
            and (
                L_Det:FindFirstChild(
                    "LeftWeld"
                )
                or L_Det:FindFirstChildWhichIsA(
                    "Weld"
                )
            )

        if not CG then
            Window:Notify({
                Title = "Blobman",
                Text = "Lock falhou.",
                Duration = 2
            })

            return
        end

        local lockEnd =
            tick()
            + Config.BlobLockHoldTime

        local packetTimer = 0
        local jumpTimer = 0

        while tick() < lockEnd do
            if not player.Parent
                or not targetRoot.Parent
            then
                break
            end

            blobRoot.CFrame =
                SavedPos

            blobRoot.Velocity =
                Vector3.zero

            local lockPos =
                SavedPos
                * CFrame.new(
                    0,
                    23,
                    0
                )

            targetRoot.CFrame =
                lockPos

            targetRoot.Velocity =
                Vector3.zero

            targetRoot.RotVelocity =
                Vector3.zero

            if tick() - packetTimer > 0.05 then
                packetTimer = tick()

                pcall(function()
                    targetHumanoid.PlatformStand =
                        true

                    targetHumanoid.Sit =
                        true

                    SetNetworkOwner:FireServer(
                        targetRoot,
                        lockPos
                    )

                    if R_Det then
                        local weld =
                            R_Det:FindFirstChild(
                                "RightWeld"
                            )
                            or R_Det:FindFirstChildWhichIsA(
                                "Weld"
                            )

                        if weld and CD then
                            CD:FireServer(
                                weld
                            )
                        end
                    end

                    DestroyGrabLine:FireServer(
                        targetRoot
                    )

                    if R_Det then
                        CG:FireServer(
                            R_Det,
                            targetRoot,
                            R_Weld
                        )
                    end

                    if L_Det and L_Weld then
                        CG:FireServer(
                            L_Det,
                            targetRoot,
                            L_Weld
                        )
                    end

                    CreateGrabLine:FireServer(
                        targetRoot,
                        Vector3.zero,
                        targetRoot.Position,
                        false
                    )
                end)
            end

            if tick() - jumpTimer
                > Config.BlobLockJumpInterval
            then
                jumpTimer = tick()

                MH.jumpFromBlob()
            end

            RunService.Heartbeat:
                Wait()
        end

        blobRoot.CFrame =
            SavedPos

        blobRoot.Velocity =
            Vector3.zero

        Window:Notify({
            Title = "Blobman",
            Text = "Lock: "
                .. player.Name,
            Duration = 2
        })
    end)
end

function State.V14.removeHighlightEsp(player)
    local highlight = State.EspHighlights[player]
    if highlight and highlight.Parent then
        highlight:Destroy()
    end
    State.EspHighlights[player] = nil

    local character = player and player.Character
    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child.Name == "MangaESPHighlight" and child:IsA("Highlight") then
                child:Destroy()
            end
        end
    end
end

function State.V14.createHighlightEsp(player)
    if not Config.EspHighlight or not player or player == LocalPlayer then
        return nil
    end
    local character = player.Character
    if not character or not character.Parent then
        return nil
    end

    State.V14.removeHighlightEsp(player)

    local highlight = Instance.new("Highlight")
    highlight.Name = "MangaESPHighlight"
    highlight:SetAttribute("MangaHubOwned", true)
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(Config.EspFillR, Config.EspFillG, Config.EspFillB)
    highlight.FillTransparency = Config.EspFillTransparency
    highlight.OutlineColor = Color3.fromRGB(Config.EspOutlineR, Config.EspOutlineG, Config.EspOutlineB)
    highlight.OutlineTransparency = Config.EspOutlineTransparency
    highlight.DepthMode = Config.EspHighlightMode == "Occluded" and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    State.EspHighlights[player] = highlight
    return highlight
end

function State.V14.removeBillboardEsp(player)
    local billboard = State.EspBillboards[player]
    if billboard and billboard.Parent then
        billboard:Destroy()
    end
    State.EspBillboards[player] = nil

    local character = player and player.Character
    if character then
        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant.Name == "MangaESPBillboard" and descendant:IsA("BillboardGui") then
                descendant:Destroy()
            end
        end
    end
end

function State.V14.createBillboardEsp(player)
    if not Config.EspBillboard or not player or player == LocalPlayer then
        return nil
    end
    local character = player.Character
    local adornee = character and (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"))
    if not adornee then
        return nil
    end

    State.V14.removeBillboardEsp(player)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MangaESPBillboard"
    billboard:SetAttribute("MangaHubOwned", true)
    billboard.Adornee = adornee
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 180, 0, 80)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.Parent = adornee

    local image = Instance.new("ImageLabel")
    image.Name = "UserImage"
    image.BackgroundTransparency = 1
    image.Size = UDim2.new(0, 48, 0, 48)
    image.Position = UDim2.new(0.5, -24, 0, 0)
    image.Visible = Config.EspIcon
    image.Parent = billboard

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = image

    local label = Instance.new("TextLabel")
    label.Name = "Username"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 28)
    label.Position = UDim2.new(0, 0, 1, -28)
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    label.TextStrokeTransparency = 0
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Text = player.DisplayName .. " (@" .. player.Name .. ")"
    label.Parent = billboard

    task.spawn(function()
        local ok, content = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        if ok and image.Parent then
            image.Image = content
        end
    end)

    State.EspBillboards[player] = billboard
    return billboard
end

function State.V14.refreshEspForPlayer(player)
    if not player or player == LocalPlayer then
        return
    end
    if Config.EspHighlight then
        State.V14.createHighlightEsp(player)
    else
        State.V14.removeHighlightEsp(player)
    end
    if Config.EspBillboard then
        State.V14.createBillboardEsp(player)
    else
        State.V14.removeBillboardEsp(player)
    end
end

function State.V14.unbindEspPlayer(player)
    local connection = State.EspCharacterConnections[player]
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end
    State.EspCharacterConnections[player] = nil
end

function State.V14.bindEspPlayer(player)
    if not player or player == LocalPlayer or State.EspCharacterConnections[player] then
        return
    end
    State.EspCharacterConnections[player] = player.CharacterAdded:Connect(function()
        task.wait(0.2)
        if player.Parent == Players then
            State.V14.refreshEspForPlayer(player)
        end
    end)
end

function State.V14.stopEspController()
    Config.EspHighlight = false
    Config.EspBillboard = false
    for player, connection in pairs(State.EspCharacterConnections) do
        if connection then
            pcall(function()
                connection:Disconnect()
            end)
        end
        State.EspCharacterConnections[player] = nil
    end
    for _, player in ipairs(Players:GetPlayers()) do
        State.V14.removeHighlightEsp(player)
        State.V14.removeBillboardEsp(player)
    end
end

if ENV.MangaEspController and ENV.MangaEspController.Stop then
    pcall(ENV.MangaEspController.Stop)
end
State.V14.EspController = {}
function State.V14.EspController.Stop()
    State.V14.stopEspController()
    if ENV.MangaEspController == State.V14.EspController then
        ENV.MangaEspController = nil
    end
end
ENV.MangaEspController = State.V14.EspController

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        State.V14.bindEspPlayer(player)
    end
end

State.V14.EspTab =
    Window:CreateTab(
        "ESP",
        "👁️"
    )

State.V14.EspHighlightSection = State.V14.EspTab:CreateSection("ESP Highlight")
State.V14.EspBillboardSection = State.V14.EspTab:CreateSection("ESP Billboard")

function State.V14.refreshAllEsp()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            State.V14.refreshEspForPlayer(player)
        end
    end
end

State.V14.EspHighlightSection:CreateToggle({
    Text = "ESP Highlight",
    Default = false,
    Flag = "EspHighlight",
    Callback = function(value)
        Config.EspHighlight = value
        State.V14.refreshAllEsp()
    end
})

for _, spec in ipairs({
    { "Fill R", "EspFillR", 255, function(v) Config.EspFillR = v end },
    { "Fill G", "EspFillG", 0, function(v) Config.EspFillG = v end },
    { "Fill B", "EspFillB", 0, function(v) Config.EspFillB = v end },
    { "Outline R", "EspOutlineR", 255, function(v) Config.EspOutlineR = v end },
    { "Outline G", "EspOutlineG", 255, function(v) Config.EspOutlineG = v end },
    { "Outline B", "EspOutlineB", 255, function(v) Config.EspOutlineB = v end }
}) do
    State.V14.EspHighlightSection:CreateSlider({
        Text = spec[1],
        Min = 0,
        Max = 255,
        Default = spec[3],
        Decimals = 0,
        Flag = spec[2],
        Callback = function(value)
            spec[4](math.floor(value + 0.5))
            State.V14.refreshAllEsp()
        end
    })
end

State.V14.EspHighlightSection:CreateSlider({
    Text = "Fill Transparency",
    Min = 0,
    Max = 1,
    Default = Config.EspFillTransparency,
    Decimals = 2,
    Flag = "EspFillTransparency",
    Callback = function(value)
        Config.EspFillTransparency = value
        State.V14.refreshAllEsp()
    end
})

State.V14.EspHighlightSection:CreateSlider({
    Text = "Outline Transparency",
    Min = 0,
    Max = 1,
    Default = Config.EspOutlineTransparency,
    Decimals = 2,
    Flag = "EspOutlineTransparency",
    Callback = function(value)
        Config.EspOutlineTransparency = value
        State.V14.refreshAllEsp()
    end
})

State.V14.EspHighlightSection:CreateDropdown({
    Text = "Highlight Mode",
    List = { "AlwaysOnTop", "Occluded" },
    Default = Config.EspHighlightMode,
    Flag = "EspHighlightMode",
    Callback = function(value)
        Config.EspHighlightMode = value
        State.V14.refreshAllEsp()
    end
})

State.V14.EspBillboardSection:CreateToggle({
    Text = "ESP Billboard",
    Default = false,
    Flag = "EspBillboard",
    Callback = function(value)
        Config.EspBillboard = value
        State.V14.refreshAllEsp()
    end
})

State.V14.EspBillboardSection:CreateToggle({
    Text = "ESP Icon",
    Default = true,
    Flag = "EspIcon",
    Callback = function(value)
        Config.EspIcon = value
        State.V14.refreshAllEsp()
    end
})

function State.V14.isAuraTarget(player)
    if not player or player == LocalPlayer or player.Parent ~= Players then
        return false
    end
    if Config.AuraWhitelistFriends then
        local ok, isFriend = pcall(function()
            return LocalPlayer:IsFriendsWith(player.UserId)
        end)
        if ok and isFriend then
            return false
        end
    end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local myRoot = State.Root
    if not humanoid or humanoid.Health <= 0 or not root or not myRoot then
        return false
    end
    return (root.Position - myRoot.Position).Magnitude <= Config.AuraRange
end

function State.V14.auraEnsurePlayerOwnership(player, root)
    if State.V14.isPlayerLocallyOwned(player) then
        return true
    end
    local now = os.clock()
    local last = State.AuraOwnershipLast[player] or 0
    if now - last >= 0.35 and root and State.Root and (root.Position - State.Root.Position).Magnitude <= 30 then
        State.AuraOwnershipLast[player] = now
        pcall(function()
            SetNetworkOwner:FireServer(root, root.CFrame)
        end)
    end
    return State.V14.isPlayerLocallyOwned(player)
end

function State.V14.auraEnsurePartOwnership(part)
    if State.V14.isPartLocallyOwned(part) then
        return true
    end
    if not part or not part.Parent or part.Anchored or not State.Root then
        return false
    end
    if (part.Position - State.Root.Position).Magnitude > 30 then
        return false
    end
    local now = os.clock()
    local last = State.AuraPartOwnershipLast[part] or 0
    if now - last >= 0.35 then
        State.AuraPartOwnershipLast[part] = now
        pcall(function()
            SetNetworkOwner:FireServer(part, part.CFrame)
        end)
    end
    return State.V14.isPartLocallyOwned(part)
end

function State.V14.destroyAuraMoverEntry(entry)
    if type(entry) ~= "table" then
        return
    end
    for _, instance in pairs(entry) do
        if typeof(instance) == "Instance" and instance.Parent then
            instance:Destroy()
        end
    end
end

function State.V14.clearAuraMoverTable(name)
    local bucket = State[name]
    if type(bucket) ~= "table" then
        return
    end
    for part, entry in pairs(bucket) do
        State.V14.destroyAuraMoverEntry(entry)
        bucket[part] = nil
    end
end

function State.V14.cleanupAuraMovers()
    State.V14.clearAuraMoverTable("AuraAttractionMovers")
    State.V14.clearAuraMoverTable("AuraTelekinesisMovers")
    State.V14.clearAuraMoverTable("AuraAnchorMovers")
end

function State.V14.ensureAttractionMover(root)
    local entry = State.AuraAttractionMovers[root]
    if entry and entry.Position and entry.Position.Parent then
        return entry.Position
    end
    local body = Instance.new("BodyPosition")
    body.Name = "MangaAttractionBody"
    body.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    body.P = 150000
    body.D = 2500
    body.Parent = root
    State.AuraAttractionMovers[root] = { Position = body }
    return body
end

function State.V14.ensureTelekinesisMover(part)
    local entry = State.AuraTelekinesisMovers[part]
    if entry and entry.Position and entry.Position.Parent and entry.Gyro and entry.Gyro.Parent then
        return entry.Position, entry.Gyro
    end
    local body = Instance.new("BodyPosition")
    body.Name = "MangaTelekinesisPosition"
    body.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    body.P = 40000
    body.D = 500
    body.Parent = part
    local gyro = Instance.new("BodyGyro")
    gyro.Name = "MangaTelekinesisGyro"
    gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    gyro.P = 40000
    gyro.D = 500
    gyro.Parent = part
    State.AuraTelekinesisMovers[part] = { Position = body, Gyro = gyro }
    return body, gyro
end

function State.V14.ensureAnchorMover(part)
    local entry = State.AuraAnchorMovers[part]
    if entry and entry.Position and entry.Position.Parent and entry.Gyro and entry.Gyro.Parent then
        return entry.Position, entry.Gyro
    end
    local body = Instance.new("BodyPosition")
    body.Name = "MangaAuraAnchorPosition"
    body.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    body.P = 40000
    body.D = 950
    body.Position = part.Position
    body.Parent = part
    local gyro = Instance.new("BodyGyro")
    gyro.Name = "MangaAuraAnchorGyro"
    gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    gyro.P = 40000
    gyro.D = 950
    gyro.CFrame = part.CFrame
    gyro.Parent = part
    State.AuraAnchorMovers[part] = { Position = body, Gyro = gyro }
    return body, gyro
end

function State.V14.auraFollowPosition()
    if Config.TelekinesisFollowType == "Mouse" then
        local mouse = LocalPlayer:GetMouse()
        if mouse and mouse.Hit then
            return mouse.Hit.Position
        end
    end
    local followPlayer = State.AuraFollowPlayer or LocalPlayer
    local character = followPlayer and followPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return root and root.Position or (State.Root and State.Root.Position)
end

function State.V14.positionTelekinesisPart(part, seed)
    local body, gyro = State.V14.ensureTelekinesisMover(part)
    local center = State.V14.auraFollowPosition()
    if not center then
        return
    end
    local theta = os.clock() * (Config.TelekinesisSpeed * 20) + seed
    local radius = Config.TelekinesisDistance
    local y = Config.TelekinesisHeight
    local destination
    if Config.TelekinesisShape == "Tornado" then
        local spiral = (seed % 6) / 6
        destination = center + Vector3.new(math.cos(theta) * radius * (0.35 + spiral), y * spiral, math.sin(theta) * radius * (0.35 + spiral))
    else
        destination = center + Vector3.new(math.cos(theta) * radius, y, math.sin(theta) * radius)
    end
    body.Position = destination
    gyro.CFrame = CFrame.lookAt(part.Position, center)
end

function State.V14.applyAuraKick(player, root)
    local auraType = Config.KickAuraType
    if auraType == "Silent" then
        local body = Instance.new("BodyPosition")
        body.Name = "MangaAuraKickSilent"
        body.MaxForce = Vector3.new(0, 12500, 0)
        body.Position = root.Position - Vector3.new(0, 4, 0)
        body.Parent = root
        task.delay(0.2, function()
            if body.Parent then body:Destroy() end
        end)
    elseif auraType == "Float" then
        local velocity = Instance.new("BodyVelocity")
        velocity.Name = "MangaAuraKickFloat"
        velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        velocity.Velocity = Vector3.new(0, 400, 0)
        velocity.Parent = root
        task.delay(0.2, function()
            if velocity.Parent then velocity:Destroy() end
        end)
    elseif auraType == "Sky Anchor" then
        local body = Instance.new("BodyPosition")
        body.Name = "MangaAuraKickSky"
        body.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        body.Position = Vector3.new(math.random(50, 250), 250, math.random(50, 250))
        body.Parent = root
        task.delay(0.25, function()
            if body.Parent then body:Destroy() end
        end)
    else
        root.AssemblyLinearVelocity = Vector3.new(0, 1000000, 0)
        pcall(function()
            DestroyGrabLine:FireServer(root)
        end)
    end
end

function State.V14.runEnabledAurasForTarget(player)
    if not State.V14.isAuraTarget(player) then
        return
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local head = character and character:FindFirstChild("Head")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then
        return
    end

    local owned = State.V14.auraEnsurePlayerOwnership(player, root)

    if Config.PoisonAura and owned then
        State.V14.applyPoisonGrab(character)
    end
    if Config.BurnAura and owned then
        State.V14.applyBurnGrab(character)
    end
    if Config.RadioactiveAura and owned then
        State.V14.applyRadioactiveGrab(character)
    end
    if Config.DeathAura and owned then
        pcall(function()
            humanoid.BreakJointsOnDeath = false
            humanoid:ChangeState(Enum.HumanoidStateType.Dead)
            humanoid.Jump = true
            humanoid.Sit = false
        end)
        local ok, state = pcall(function() return humanoid:GetState() end)
        if ok and state == Enum.HumanoidStateType.Dead then
            pcall(function() DestroyGrabLine:FireServer(root) end)
        end
    end
    if Config.AttractionAura and owned and State.Root then
        local body = State.V14.ensureAttractionMover(root)
        body.Position = State.Root.Position
        humanoid.Sit = false
    end
    if Config.FlingAuraEnabled and owned and (Config.FlingAuraTarget == "Players" or Config.FlingAuraTarget == "Players and Objects") and State.Root then
        local delta = root.Position - State.Root.Position
        local direction = delta.Magnitude > 0.01 and delta.Unit or Vector3.new(0, 1, 0)
        local velocity = Instance.new("BodyVelocity")
        velocity.Name = "MangaAuraFling"
        velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        velocity.Velocity = Vector3.new(direction.X, 0.5, direction.Z).Unit * Config.FlingAuraStrength
        velocity.Parent = root
        task.delay(0.12, function()
            if velocity.Parent then velocity:Destroy() end
        end)
    end
    if Config.TelekinesisAura and Config.TelekinesisMode == "Aura" and owned and (Config.TelekinesisTarget == "Players" or Config.TelekinesisTarget == "Players and Objects") then
        State.V14.positionTelekinesisPart(root, player.UserId % 100)
    end
    if Config.AnchorAura and owned and (Config.AnchorAuraTarget == "Players" or Config.AnchorAuraTarget == "Players and Objects") then
        State.V14.ensureAnchorMover(root)
    end
    if Config.KickAura and owned then
        State.V14.applyAuraKick(player, root)
    end
end

function State.V14.isObjectAuraPart(part)
    if not part or not part:IsA("BasePart") or part.Anchored or not part.Parent or not State.Root then
        return false
    end
    if LocalPlayer.Character and part:IsDescendantOf(LocalPlayer.Character) then
        return false
    end
    local grabParts = Workspace:FindFirstChild("GrabParts")
    if grabParts and part:IsDescendantOf(grabParts) then
        return false
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and part:IsDescendantOf(player.Character) then
            return false
        end
    end
    return (part.Position - State.Root.Position).Magnitude <= Config.AuraRange
end

function State.V14.runObjectAuraPulse()
    if not State.Root then
        return
    end
    local wantsObjects = (Config.FlingAuraEnabled and (Config.FlingAuraTarget == "Objects" or Config.FlingAuraTarget == "Players and Objects"))
        or (Config.TelekinesisAura and Config.TelekinesisMode == "Aura" and (Config.TelekinesisTarget == "Objects" or Config.TelekinesisTarget == "Players and Objects"))
        or (Config.AnchorAura and (Config.AnchorAuraTarget == "Objects" or Config.AnchorAuraTarget == "Players and Objects"))
    if not wantsObjects then
        return
    end

    local parts = {}
    local ok, found = pcall(function()
        return Workspace:GetPartBoundsInRadius(State.Root.Position, Config.AuraRange)
    end)
    if ok and type(found) == "table" then
        parts = found
    end

    local handled = 0
    for _, part in ipairs(parts) do
        if State.V14.isObjectAuraPart(part) and State.V14.auraEnsurePartOwnership(part) then
            if Config.FlingAuraEnabled and (Config.FlingAuraTarget == "Objects" or Config.FlingAuraTarget == "Players and Objects") then
                local delta = part.Position - State.Root.Position
                local direction = delta.Magnitude > 0.01 and delta.Unit or Vector3.new(0, 1, 0)
                part.AssemblyLinearVelocity = Vector3.new(direction.X, 0.5, direction.Z).Unit * Config.FlingAuraStrength
            end
            if Config.TelekinesisAura and Config.TelekinesisMode == "Aura" and (Config.TelekinesisTarget == "Objects" or Config.TelekinesisTarget == "Players and Objects") then
                State.V14.positionTelekinesisPart(part, handled)
            end
            if Config.AnchorAura and (Config.AnchorAuraTarget == "Objects" or Config.AnchorAuraTarget == "Players and Objects") then
                State.V14.ensureAnchorMover(part)
            end
            handled = handled + 1
            if handled >= 12 then
                break
            end
        end
    end
end

function State.V14.auraAnyEnabled()
    return Config.PoisonAura or Config.DeathAura or Config.RadioactiveAura or Config.BurnAura or Config.AttractionAura
        or Config.FlingAuraEnabled or Config.TelekinesisAura or Config.AnchorAura or Config.KickAura
end

function State.V14.stopAuraController()
    State.V14.cancelWorker("AuraController")
    State.AuraControllerRunning = false
    State.V14.cleanupAuraMovers()
end

function State.V14.startAuraController()
    if State.AuraControllerRunning then
        return
    end
    State.AuraControllerRunning = true
    local token = State.V14.newWorkerToken("AuraController")
    task.spawn(function()
        while State.V14.workerTokenAlive("AuraController", token) and State.AuraControllerRunning do
            if not State.V14.auraAnyEnabled() then
                break
            end
            for _, player in ipairs(Players:GetPlayers()) do
                State.V14.runEnabledAurasForTarget(player)
            end

            if Config.TelekinesisAura and Config.TelekinesisMode == "Click" then
                local _, part, character, player = State.V14.getActiveGrabContext()
                if part then
                    local canOwn = player and State.V14.auraEnsurePlayerOwnership(player, part) or State.V14.auraEnsurePartOwnership(part)
                    if canOwn then
                        State.V14.positionTelekinesisPart(part, 0)
                    end
                end
            end

            State.V14.runObjectAuraPulse()

            if not Config.AttractionAura then
                State.V14.clearAuraMoverTable("AuraAttractionMovers")
            end
            if not Config.TelekinesisAura then
                State.V14.clearAuraMoverTable("AuraTelekinesisMovers")
            end
            if not Config.AnchorAura then
                State.V14.clearAuraMoverTable("AuraAnchorMovers")
            end

            task.wait(0.1)
        end
        if State.FeatureWorkerTokens.AuraController == token then
            State.AuraControllerRunning = false
        end
        State.V14.cleanupAuraMovers()
    end)
end

function State.V14.auraToggleChanged(field, value)
    Config[field] = value
    if value then
        State.V14.startAuraController()
    elseif not State.V14.auraAnyEnabled() then
        State.V14.stopAuraController()
    end
end

function State.V14.buildAuraPlayerList()
    local list = {}
    local map = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local label = string.format("%s (@%s)", player.DisplayName, player.Name)
        table.insert(list, label)
        map[label] = player
    end
    table.sort(list)
    return list, map
end

State.V14.GrabAurasTab =
    Window:CreateTab(
        "Grab Auras",
        "🌀"
    )

State.V14.NormalAurasSection = State.V14.GrabAurasTab:CreateSection("Normal Auras")
State.V14.FlingAuraSection = State.V14.GrabAurasTab:CreateSection("Fling Aura")
State.V14.TelekinesisAuraSection = State.V14.GrabAurasTab:CreateSection("Telekinesis Aura")
State.V14.AnchorAuraSection = State.V14.GrabAurasTab:CreateSection("Anchor Aura")
State.V14.KickAuraSection = State.V14.GrabAurasTab:CreateSection("Kick Aura")
State.V14.AuraWhitelistSection = State.V14.GrabAurasTab:CreateSection("Aura Whitelist")

for _, spec in ipairs({
    { "Poison Aura", "PoisonAura" },
    { "Death Aura", "DeathAura" },
    { "Radioactive Aura", "RadioactiveAura" },
    { "Burn Aura", "BurnAura" },
    { "Attraction Aura", "AttractionAura" }
}) do
    State.V14.NormalAurasSection:CreateToggle({
        Text = spec[1],
        Default = false,
        Flag = spec[2],
        Callback = function(value)
            State.V14.auraToggleChanged(spec[2], value)
        end
    })
end

State.V14.FlingAuraSection:CreateToggle({
    Text = "Fling Aura",
    Default = false,
    Flag = "AuraFling",
    Callback = function(value)
        State.V14.auraToggleChanged("FlingAuraEnabled", value)
    end
})

State.V14.FlingAuraSection:CreateSlider({
    Text = "Strength",
    Min = 400,
    Max = 10000,
    Default = Config.FlingAuraStrength,
    Decimals = 0,
    Flag = "AuraFlingStrength",
    Callback = function(value)
        Config.FlingAuraStrength = value
    end
})

State.V14.FlingAuraSection:CreateDropdown({
    Text = "Target",
    List = { "Players", "Objects", "Players and Objects" },
    Default = Config.FlingAuraTarget,
    Flag = "AuraFlingTarget",
    Callback = function(value)
        Config.FlingAuraTarget = value
    end
})

State.V14.TelekinesisAuraSection:CreateToggle({
    Text = "Telekinesis Aura",
    Default = false,
    Flag = "TelekinesisAura",
    Callback = function(value)
        State.V14.auraToggleChanged("TelekinesisAura", value)
    end
})

State.V14.TelekinesisAuraSection:CreateDropdown({
    Text = "Mode",
    List = { "Click", "Aura" },
    Default = Config.TelekinesisMode,
    Flag = "TelekinesisMode",
    Callback = function(value)
        Config.TelekinesisMode = value
    end
})

State.V14.TelekinesisAuraSection:CreateDropdown({
    Text = "Shape",
    List = { "Blackhole", "Tornado" },
    Default = Config.TelekinesisShape,
    Flag = "TelekinesisShape",
    Callback = function(value)
        Config.TelekinesisShape = value
    end
})

State.V14.TelekinesisAuraSection:CreateDropdown({
    Text = "Follow Type",
    List = { "Player", "Mouse" },
    Default = Config.TelekinesisFollowType,
    Flag = "TelekinesisFollowType",
    Callback = function(value)
        Config.TelekinesisFollowType = value
    end
})

State.V14.auraPlayers, State.V14.auraPlayerMap = State.V14.buildAuraPlayerList()
State.AuraFollowPlayerMap = State.V14.auraPlayerMap
State.AuraFollowPlayer = LocalPlayer
State.V14.AuraFollowPlayerDropdown = State.V14.TelekinesisAuraSection:CreateDropdown({
    Text = "Follow Player",
    List = State.V14.auraPlayers,
    Default = string.format("%s (@%s)", LocalPlayer.DisplayName, LocalPlayer.Name),
    Flag = "AuraFollowPlayer",
    Callback = function(value)
        State.AuraFollowPlayer = State.AuraFollowPlayerMap[value] or LocalPlayer
    end
})

State.V14.TelekinesisAuraSection:CreateDropdown({
    Text = "Target",
    List = { "Players", "Objects", "Players and Objects" },
    Default = Config.TelekinesisTarget,
    Flag = "TelekinesisTarget",
    Callback = function(value)
        Config.TelekinesisTarget = value
    end
})

State.V14.TelekinesisAuraSection:CreateSlider({
    Text = "Distance",
    Min = 5,
    Max = 1000,
    Default = Config.TelekinesisDistance,
    Decimals = 0,
    Flag = "TelekinesisDistance",
    Callback = function(value)
        Config.TelekinesisDistance = value
    end
})

State.V14.TelekinesisAuraSection:CreateSlider({
    Text = "Height",
    Min = 5,
    Max = 1000,
    Default = Config.TelekinesisHeight,
    Decimals = 0,
    Flag = "TelekinesisHeight",
    Callback = function(value)
        Config.TelekinesisHeight = value
    end
})

State.V14.TelekinesisAuraSection:CreateSlider({
    Text = "Speed",
    Min = 0.01,
    Max = 0.5,
    Default = Config.TelekinesisSpeed,
    Decimals = 2,
    Flag = "TelekinesisSpeed",
    Callback = function(value)
        Config.TelekinesisSpeed = value
    end
})

State.V14.TelekinesisAuraSection:CreateButton({
    Text = "Disconnect All",
    Callback = function()
        State.V14.clearAuraMoverTable("AuraTelekinesisMovers")
    end
})

State.V14.AnchorAuraSection:CreateToggle({
    Text = "Anchor Aura",
    Default = false,
    Flag = "AnchorAura",
    Callback = function(value)
        State.V14.auraToggleChanged("AnchorAura", value)
    end
})

State.V14.AnchorAuraSection:CreateDropdown({
    Text = "Target",
    List = { "Players", "Objects", "Players and Objects" },
    Default = Config.AnchorAuraTarget,
    Flag = "AnchorAuraTarget",
    Callback = function(value)
        Config.AnchorAuraTarget = value
    end
})

State.V14.KickAuraSection:CreateToggle({
    Text = "Kick Aura",
    Default = false,
    Flag = "KickAura",
    Callback = function(value)
        State.V14.auraToggleChanged("KickAura", value)
    end
})

State.V14.KickAuraSection:CreateDropdown({
    Text = "Kick Type",
    List = { "Go to the heaven!", "Silent", "Float", "Sky Anchor" },
    Default = Config.KickAuraType,
    Flag = "KickAuraType",
    Callback = function(value)
        Config.KickAuraType = value
    end
})

State.V14.AuraWhitelistSection:CreateToggle({
    Text = "Whitelist Friends",
    Default = false,
    Flag = "AuraWhitelistFriends",
    Callback = function(value)
        Config.AuraWhitelistFriends = value
    end
})

State.V14.ExplosionTypeMap = {
    Firework = "FireworkMissile",
    Missile = "BombMissile",
    Void = "BombDarkMatter",
    Balloon = "BombBalloon",
    ["Small Present"] = "PresentSmall",
    ["Big Present"] = "PresentBig"
}

function State.V14.getExplosionCapabilities()
    local menuToys = ReplicatedStorage:FindFirstChild("MenuToys")
    local spawnToy = menuToys and menuToys:FindFirstChild("SpawnToyRemoteFunction")
    local destroyToy = menuToys and menuToys:FindFirstChild("DestroyToy")
    local bombEvents = ReplicatedStorage:FindFirstChild("BombEvents")
    local bombExplode = bombEvents and bombEvents:FindFirstChild("BombExplode")
    local toyFolder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    local toyCap = LocalPlayer:FindFirstChild("ToysLimitCap")
    local hasSnowball = false

    if toyFolder and toyFolder:FindFirstChild("BallSnowball") then
        hasSnowball = true
    elseif ReplicatedStorage:FindFirstChild("BallSnowball", true) then
        hasSnowball = true
    end

    return {
        MenuToys = menuToys,
        SpawnToy = spawnToy,
        DestroyToy = destroyToy,
        BombExplode = bombExplode,
        ToyFolder = toyFolder,
        ToyCap = toyCap,
        CanSpawn = spawnToy ~= nil,
        CanDestroy = destroyToy ~= nil,
        CanExplode = bombExplode ~= nil,
        HasSnowball = hasSnowball
    }
end

function State.V14.explosionHitboxForToy(toy, internalType)
    if not toy then
        return nil
    end
    if internalType == "PresentBig" or internalType == "PresentSmall" then
        return toy:FindFirstChild("Box", true)
    end
    if internalType == "BombBalloon" then
        return toy:FindFirstChild("Balloon", true)
    end
    if internalType == "BombMissile" then
        return toy:FindFirstChild("Body", true)
    end
    if internalType == "BombDarkMatter" then
        return toy:FindFirstChild("Pyramid", true)
    end
    if internalType == "FireworkMissile" then
        return toy:FindFirstChild("Hitbox", true) or toy:FindFirstChild("PartHitDetector", true)
    end
    return toy:FindFirstChild("PartHitDetector", true)
end

function State.V14.explosionTargetData()
    if Config.ExplosionTarget == "Player" then
        local player = State.ExplosionSelectedPlayer
        local character = player and player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root then
            return root, root.Position
        end
        return nil, nil
    end

    if Config.ExplosionTarget == "Mouse" then
        local mouse = LocalPlayer:GetMouse()
        local hit = mouse and mouse.Hit
        if hit then
            local root = State.Root or Workspace:FindFirstChild("SpawnLocation")
            return root, hit.Position
        end
        return nil, nil
    end

    local spawnLocation = Workspace:FindFirstChild("SpawnLocation")
    local positionPart = spawnLocation or State.Root
    if not positionPart then
        return nil, nil
    end
    return positionPart, positionPart.Position + Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
end

function State.V14.trackExplosionToy(toy)
    if toy and toy.Parent then
        State.ExplosionTrackedToys[toy] = true
    end
end

function State.V14.cleanupExplosionToys()
    local capabilities = State.V14.getExplosionCapabilities()
    for toy in pairs(State.ExplosionTrackedToys) do
        if toy and toy.Parent and capabilities.DestroyToy then
            pcall(function()
                capabilities.DestroyToy:FireServer(toy)
            end)
        end
        State.ExplosionTrackedToys[toy] = nil
    end
end

function State.V14.findNewExplosionToy(folder, internalType)
    if not folder then
        return nil
    end
    for _, toy in ipairs(folder:GetChildren()) do
        if toy.Name == internalType and not State.ExplosionTrackedToys[toy] then
            return toy
        end
    end
    return nil
end

function State.V14.spawnExplosionToy(capabilities, internalType)
    if not capabilities.CanSpawn or not State.Root then
        return nil
    end
    local before = {}
    if capabilities.ToyFolder then
        for _, child in ipairs(capabilities.ToyFolder:GetChildren()) do
            before[child] = true
        end
    end
    pcall(function()
        capabilities.SpawnToy:InvokeServer(internalType, State.Root.CFrame, Vector3.new(0, 97.69, 0))
    end)
    task.wait(0.08)
    local folder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            if child.Name == internalType and not before[child] and not State.ExplosionTrackedToys[child] then
                State.V14.trackExplosionToy(child)
                return child
            end
        end
    end
    local fallback = State.V14.findNewExplosionToy(folder, internalType)
    if fallback then
        State.V14.trackExplosionToy(fallback)
    end
    return fallback
end

function State.V14.requestExplosionOwnership(hitbox)
    if not hitbox or not hitbox:IsA("BasePart") then
        return false
    end
    if State.V14.isPartLocallyOwned(hitbox) then
        return true
    end
    for _ = 1, 2 do
        pcall(function()
            SetNetworkOwner:FireServer(hitbox, hitbox.CFrame)
        end)
        task.wait()
        if State.V14.isPartLocallyOwned(hitbox) then
            return true
        end
    end
    return false
end

function State.V14.explodeTrackedToy(capabilities, toy, internalType)
    if not capabilities.CanExplode or not toy or not toy.Parent then
        return false
    end
    local hitbox = State.V14.explosionHitboxForToy(toy, internalType)
    if not hitbox or not State.V14.requestExplosionOwnership(hitbox) then
        return false
    end
    local positionPart, targetPosition = State.V14.explosionTargetData()
    if not positionPart or not targetPosition then
        return false
    end
    local payload = {
        Radius = 17.5,
        TimeLength = 0.5,
        Hitbox = hitbox,
        ExplodesByFire = true,
        MaxForcePerStudSquared = 225,
        DestroysModel = true,
        Model = toy,
        ExplodesByPointy = false,
        ImpactSpeed = 20,
        PositionPart = positionPart
    }
    pcall(function()
        capabilities.BombExplode:FireServer(payload, targetPosition)
    end)
    return true
end

function State.V14.stopExplosionSpam()
    Config.ExplosionEnabled = false
    State.V14.cancelWorker("ExplosionSpam")
    State.V14.cleanupExplosionToys()
end

function State.V14.startExplosionSpam()
    State.V14.stopExplosionSpam()
    local capabilities = State.V14.getExplosionCapabilities()
    if not capabilities.CanSpawn or not capabilities.CanExplode then
        State.V14.warnFeatureOnce("Explosions", "BombEvents or SpawnToyRemoteFunction is unavailable.")
        return
    end

    Config.ExplosionEnabled = true
    local token = State.V14.newWorkerToken("ExplosionSpam")
    task.spawn(function()
        while State.V14.workerTokenAlive("ExplosionSpam", token) and Config.ExplosionEnabled do
            local internalType = State.V14.ExplosionTypeMap[Config.ExplosionType]
            if not internalType then
                break
            end

            local live = {}
            local count = 0
            for toy in pairs(State.ExplosionTrackedToys) do
                if toy and toy.Parent and toy.Name == internalType then
                    live[toy] = true
                    count = count + 1
                else
                    State.ExplosionTrackedToys[toy] = nil
                end
            end

            while count < Config.ExplosionAmount and State.V14.workerTokenAlive("ExplosionSpam", token) and Config.ExplosionEnabled do
                local toy = State.V14.spawnExplosionToy(State.V14.getExplosionCapabilities(), internalType)
                if not toy then
                    break
                end
                live[toy] = true
                count = count + 1
            end

            capabilities = State.V14.getExplosionCapabilities()
            for toy in pairs(live) do
                if not State.V14.workerTokenAlive("ExplosionSpam", token) or not Config.ExplosionEnabled then
                    break
                end
                State.V14.explodeTrackedToy(capabilities, toy, internalType)
                if Config.ExplosionDelay > 0 then
                    task.wait(Config.ExplosionDelay)
                end
            end

            task.wait(0.08)
        end
        if State.FeatureWorkerTokens.ExplosionSpam == token then
            Config.ExplosionEnabled = false
        end
        State.V14.cleanupExplosionToys()
    end)
end

function State.V14.makeSnowballsOnce()
    local capabilities = State.V14.getExplosionCapabilities()
    if not capabilities.HasSnowball or not capabilities.CanSpawn then
        State.V14.warnFeatureOnce("Snowball", "BallSnowball is not available in this server/season.")
        return false
    end
    local folder = capabilities.ToyFolder
    local count = 0
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            if child.Name == "BallSnowball" then
                count = count + 1
            end
        end
    end
    while count < Config.SnowballAmount do
        pcall(function()
            capabilities.SpawnToy:InvokeServer("BallSnowball", State.Root and State.Root.CFrame or CFrame.new(), Vector3.new(0, 97.69, 0))
        end)
        count = count + 1
        task.wait(0.1)
    end
    return true
end

function State.V14.explodeSnowballsOnce()
    local capabilities = State.V14.getExplosionCapabilities()
    if not capabilities.HasSnowball or not capabilities.CanExplode or not capabilities.ToyFolder then
        State.V14.warnFeatureOnce("Snowball", "Snowball explosion is unavailable right now.")
        return false
    end
    for _, toy in ipairs(capabilities.ToyFolder:GetChildren()) do
        if toy.Name == "BallSnowball" then
            local hitbox = toy:FindFirstChild("SoundPart", true) or toy:FindFirstChildWhichIsA("BasePart", true)
            if hitbox and State.V14.requestExplosionOwnership(hitbox) then
                local positionPart, targetPosition = State.V14.explosionTargetData()
                if positionPart and targetPosition then
                    pcall(function()
                        capabilities.BombExplode:FireServer({
                            Radius = 17.5,
                            TimeLength = 0.5,
                            Hitbox = hitbox,
                            ExplodesByFire = true,
                            MaxForcePerStudSquared = 225,
                            DestroysModel = true,
                            Model = toy,
                            ExplodesByPointy = false,
                            ImpactSpeed = 20,
                            PositionPart = positionPart
                        }, targetPosition)
                    end)
                end
            end
        end
    end
    return true
end

State.V14.ExplosionsTab =
    Window:CreateTab(
        "Explosions",
        "💥"
    )

State.V14.ExplosionSection = State.V14.ExplosionsTab:CreateSection("Explosions Spam")
State.V14.SnowballSection = State.V14.ExplosionsTab:CreateSection("Snowball")

State.V14.ExplosionSection:CreateToggle({
    Text = "Explode",
    Default = false,
    Flag = "ExplosionSpam",
    Callback = function(value)
        State.FeatureWarnings.Explosions = nil
        if value then
            State.V14.startExplosionSpam()
        else
            State.V14.stopExplosionSpam()
        end
    end
})

State.V14.ExplosionSection:CreateDropdown({
    Text = "Explosion Type",
    List = { "Firework", "Missile", "Void", "Balloon", "Small Present", "Big Present" },
    Default = Config.ExplosionType,
    Flag = "ExplosionType",
    Callback = function(value)
        Config.ExplosionType = value
    end
})

State.V14.ExplosionSection:CreateSlider({
    Text = "Amount to Explode",
    Min = 1,
    Max = 18,
    Default = Config.ExplosionAmount,
    Decimals = 0,
    Flag = "ExplosionAmount",
    Callback = function(value)
        Config.ExplosionAmount = math.floor(value + 0.5)
    end
})

State.V14.ExplosionSection:CreateSlider({
    Text = "Delay",
    Min = 0,
    Max = 1,
    Default = Config.ExplosionDelay,
    Decimals = 1,
    Flag = "ExplosionDelay",
    Callback = function(value)
        Config.ExplosionDelay = value
    end
})

State.V14.ExplosionSection:CreateDropdown({
    Text = "Target",
    List = { "Spawn", "Player", "Mouse" },
    Default = Config.ExplosionTarget,
    Flag = "ExplosionTarget",
    Callback = function(value)
        Config.ExplosionTarget = value
    end
})

State.V14.explosionPlayers, State.V14.explosionMap = MH.buildPlayerList()
State.ExplosionPlayerMap = State.V14.explosionMap
State.ExplosionSelectedPlayer = State.V14.explosionMap[State.V14.explosionPlayers[1]]
State.V14.ExplosionPlayerDropdown = State.V14.ExplosionSection:CreateDropdown({
    Text = "Select Player",
    List = State.V14.explosionPlayers,
    Default = State.V14.explosionPlayers[1],
    Flag = "ExplosionPlayer",
    Callback = function(value)
        State.ExplosionSelectedPlayer = State.ExplosionPlayerMap[value]
    end
})

State.V14.SnowballSection:CreateSlider({
    Text = "Amount",
    Min = 5,
    Max = 200,
    Default = Config.SnowballAmount,
    Decimals = 0,
    Flag = "SnowballAmount",
    Callback = function(value)
        Config.SnowballAmount = math.floor(value + 0.5)
    end
})

State.V14.SnowballSection:CreateToggle({
    Text = "Auto Make Snowball",
    Default = false,
    Flag = "AutoMakeSnowball",
    Callback = function(value)
        Config.AutoMakeSnowball = value
        State.FeatureWarnings.Snowball = nil
        if value then
            task.spawn(function()
                while Config.AutoMakeSnowball and State.Running do
                    if State.V14.makeSnowballsOnce() then
                        Config.AutoMakeSnowball = false
                        break
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

State.V14.SnowballSection:CreateButton({
    Text = "Explode Snowballs",
    Callback = function()
        State.FeatureWarnings.Snowball = nil
        State.V14.explodeSnowballsOnce()
    end
})

State.V14.TeleportLocations = {
    ["Green House"] = CFrame.new(-352, 99, 354),
    ["Green Safe-House"] = CFrame.new(-584, -6, 93),
    ["Chinese Safe-House"] = CFrame.new(579, 124, -94),
    ["Farm House"] = CFrame.new(-234, 83, -324),
    ["Spawn"] = CFrame.new(4, -7, -3),
    ["Blue Safe-House"] = CFrame.new(538, 96, -372),
    ["Secret Big Cave"] = CFrame.new(17, -7, 539),
    ["Secret Train Cave"] = CFrame.new(500, 62, -307),
    ["Mine Cave"] = CFrame.new(-254, -7, 518),
    ["Witch Safe-House"] = CFrame.new(296, -4, 494),
    ["Red Safe-House"] = CFrame.new(-516, -6, -162)
}

function State.V14.teleportLocalPlayer(cframe)
    if typeof(cframe) ~= "CFrame" then
        return false
    end
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then
        return false
    end

    local seatedInBlob = false
    local seatPart = humanoid.SeatPart
    if seatPart then
        local current = seatPart
        while current and current ~= Workspace do
            if current:IsA("Model") and current.Name == "CreatureBlobman" then
                seatedInBlob = true
                break
            end
            current = current.Parent
        end
    end

    if not seatedInBlob then
        humanoid.Sit = false
    end
    root.CFrame = cframe
    return true
end

function State.V14.resolveTeleportTarget(name)
    if typeof(name) == "Instance" and name:IsA("Player") then
        return name.Parent == Players and name or nil
    end
    if type(name) ~= "string" then
        return nil
    end
    local direct = Players:FindFirstChild(name)
    if direct and direct:IsA("Player") then
        return direct
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.DisplayName == name then
            return player
        end
    end
    return nil
end

function State.V14.teleportToPlayer(player, direction, offset)
    if not player or player == LocalPlayer or player.Parent ~= Players then
        return false
    end
    local character = player.Character
    local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return false
    end

    local amount = math.max(1, tonumber(offset) or 1) + 1
    local behavior = direction or Config.TeleportBehavior
    local targetCFrame = targetRoot.CFrame
    local destination

    if behavior == "Front" then
        destination = CFrame.new(targetCFrame.Position + targetCFrame.LookVector * amount)
    elseif behavior == "Right" then
        destination = CFrame.new(targetCFrame.Position + targetCFrame.RightVector * amount)
    elseif behavior == "Left" then
        destination = CFrame.new(targetCFrame.Position - targetCFrame.RightVector * amount)
    elseif behavior == "Rotate" then
        State.TeleportRotation = State.TeleportRotation + 0.1
        local pos = targetCFrame.Position + Vector3.new(math.cos(State.TeleportRotation), 0, math.sin(State.TeleportRotation)) * amount
        destination = CFrame.new(pos, targetCFrame.Position)
    else
        destination = CFrame.new(targetCFrame.Position - targetCFrame.LookVector * amount)
    end

    return State.V14.teleportLocalPlayer(destination)
end

function State.V14.stopLoopTeleport()
    Config.LoopTeleport = false
    State.V14.cancelWorker("LoopTeleport")
end

function State.V14.startLoopTeleport()
    local token = State.V14.newWorkerToken("LoopTeleport")
    Config.LoopTeleport = true
    task.spawn(function()
        while State.V14.workerTokenAlive("LoopTeleport", token) and Config.LoopTeleport do
            local player = State.TeleportSelectedPlayer
            if not player or player.Parent ~= Players then
                break
            end
            if not State.V14.teleportToPlayer(player, Config.TeleportBehavior, Config.TeleportOffset) then
                break
            end
            task.wait()
        end
        if State.FeatureWorkerTokens.LoopTeleport == token then
            Config.LoopTeleport = false
        end
    end)
end

function State.V14.stopLockCamera()
    Config.LockCamera = false
    State.V14.disconnectFeatureBucket("TeleportLockCamera")
end

function State.V14.startLockCamera()
    State.V14.stopLockCamera()
    Config.LockCamera = true
    State.V14.trackFeatureConnection("TeleportLockCamera", RunService.RenderStepped:Connect(function()
        if not Config.LockCamera then
            State.V14.stopLockCamera()
            return
        end
        local player = State.TeleportSelectedPlayer
        local character = player and player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local camera = Workspace.CurrentCamera
        if not player or player.Parent ~= Players or not root or not camera then
            State.V14.stopLockCamera()
            return
        end
        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, root.Position + Vector3.new(0, 1, 0))
    end))
end

function State.V14.stopViewPlayer()
    Config.ViewPlayer = false
    State.V14.disconnectFeatureBucket("TeleportView")
    local camera = Workspace.CurrentCamera
    if camera then
        local saved = State.TeleportViewSavedSubject
        if saved and saved.Parent then
            camera.CameraSubject = saved
        elseif State.Humanoid and State.Humanoid.Parent then
            camera.CameraSubject = State.Humanoid
        end
    end
    State.TeleportViewSavedSubject = nil
end

function State.V14.startViewPlayer()
    State.V14.stopViewPlayer()
    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end
    State.TeleportViewSavedSubject = camera.CameraSubject
    Config.ViewPlayer = true
    State.V14.trackFeatureConnection("TeleportView", RunService.RenderStepped:Connect(function()
        if not Config.ViewPlayer then
            State.V14.stopViewPlayer()
            return
        end
        local player = State.TeleportSelectedPlayer
        local character = player and player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not player or player.Parent ~= Players or not humanoid or not camera then
            State.V14.stopViewPlayer()
            return
        end
        camera.CameraSubject = humanoid
    end))
end

State.V14.TeleportTab =
    Window:CreateTab(
        "Teleport",
        "🌀"
    )

State.V14.PlaceTeleportSection = State.V14.TeleportTab:CreateSection("Place TP")
State.V14.PlayerTeleportSection = State.V14.TeleportTab:CreateSection("Player TP")

State.V14.placeNames = {
    "Green House", "Chinese Safe-House", "Spawn", "Blue Safe-House",
    "Secret Big Cave", "Secret Train Cave", "Mine Cave", "Farm House",
    "Witch Safe-House", "Green Safe-House", "Red Safe-House"
}

State.V14.PlaceTeleportSection:CreateDropdown({
    Text = "Place to Teleport",
    List = State.V14.placeNames,
    Default = Config.TeleportPlace,
    Flag = "TeleportPlace",
    Callback = function(value)
        Config.TeleportPlace = value
    end
})

State.V14.PlaceTeleportSection:CreateButton({
    Text = "Teleport",
    Callback = function()
        State.V14.teleportLocalPlayer(State.V14.TeleportLocations[Config.TeleportPlace])
    end
})

State.V14.teleportPlayers, State.V14.teleportMap = MH.buildPlayerList()
State.TeleportPlayerMap = State.V14.teleportMap
State.TeleportSelectedPlayer = State.V14.teleportMap[State.V14.teleportPlayers[1]]

State.V14.TeleportPlayerDropdown = State.V14.PlayerTeleportSection:CreateDropdown({
    Text = "Select Player",
    List = State.V14.teleportPlayers,
    Default = State.V14.teleportPlayers[1],
    Flag = "TeleportPlayer",
    Callback = function(value)
        State.TeleportSelectedPlayer = State.TeleportPlayerMap[value]
        State.TeleportRotation = 0
    end
})

State.V14.PlayerTeleportSection:CreateButton({
    Text = "Teleport",
    Callback = function()
        State.V14.teleportToPlayer(State.TeleportSelectedPlayer, Config.TeleportBehavior, Config.TeleportOffset)
    end
})

State.V14.PlayerTeleportSection:CreateToggle({
    Text = "Loop Teleport",
    Default = false,
    Flag = "LoopTeleport",
    Callback = function(value)
        if value then
            State.V14.startLoopTeleport()
        else
            State.V14.stopLoopTeleport()
        end
    end
})

State.V14.PlayerTeleportSection:CreateToggle({
    Text = "Lock Camera",
    Default = false,
    Flag = "LockCamera",
    Callback = function(value)
        if value then
            State.V14.startLockCamera()
        else
            State.V14.stopLockCamera()
        end
    end
})

State.V14.PlayerTeleportSection:CreateToggle({
    Text = "View",
    Default = false,
    Flag = "ViewPlayer",
    Callback = function(value)
        if value then
            State.V14.startViewPlayer()
        else
            State.V14.stopViewPlayer()
        end
    end
})

State.V14.PlayerTeleportSection:CreateSlider({
    Text = "Offset",
    Min = 1,
    Max = 20,
    Default = Config.TeleportOffset,
    Decimals = 0,
    Flag = "TeleportOffset",
    Callback = function(value)
        Config.TeleportOffset = math.floor(value + 0.5)
    end
})

State.V14.PlayerTeleportSection:CreateDropdown({
    Text = "Behavior",
    List = { "Behind", "Left", "Right", "Front", "Rotate" },
    Default = Config.TeleportBehavior,
    Flag = "TeleportBehavior",
    Callback = function(value)
        Config.TeleportBehavior = value
        State.TeleportRotation = 0
    end
})

BlobTab =
    Window:CreateTab(
        "Blob Control",
        "🧬"
    )

BlobSection =
    BlobTab:
        CreateSection(
            "Player Control"
        )

initialPlayers,
    initialMap =
    MH.buildPlayerList()

State.BlobPlayerMap =
    initialMap

BlobDropdown =
    BlobSection:
        CreateDropdown({
            Text = "Selecionar player",
            List = initialPlayers,
            Default = initialPlayers[1],
            Flag = "BlobPlayer",

            Callback = function(value)
                State.BlobSelectedPlayer =
                    State.BlobPlayerMap[
                        value
                    ]

                selectedKickPlayer =
                    State.BlobPlayerMap[
                        value
                    ]
            end
        })

State.BlobSelectedPlayer =
    State.BlobPlayerMap[
        initialPlayers[1]
    ]

selectedKickPlayer =
    State.BlobPlayerMap[
        initialPlayers[1]
    ]

BlobSection:CreateButton({
    Text = "Lock Player",
    Callback = MH.lockBlobPlayer
})

BlobSection:CreateButton({
    Text = "Bring Player",
    Callback = MH.bringBlobPlayer
})

BlobSection:CreateButton({
    Text = "Kick",
    Callback = function()
        if State.BlobSelectedPlayer then
            State.V14.blobmanGrabPlayer(State.BlobSelectedPlayer, "Kick")
        end
    end
})

BlobSection:CreateToggle({
    Text = "Loop Kick",
    Default = false,
    Flag = "BlobLoopKick",
    Callback = function(value)
        if value then
            State.V14.startBlobmanLoopKick()
        else
            State.V14.stopBlobmanLoopKick()
        end
    end
})

BlobSection:CreateToggle({
    Text = "Whitelist Friends",
    Default = false,
    Flag = "BlobWhitelistFriends",
    Callback = function(value)
        Config.BlobWhitelistFriends = value
    end
})

BlobSection:CreateToggle({
    Text = "Destroy Server",
    Default = false,
    Flag = "BlobDestroyServer",
    Callback = function(value)
        if value then
            State.V14.startBlobmanDestroyServer()
        else
            State.V14.stopBlobmanDestroyServer()
        end
    end
})

kickToggle =
    BlobSection:
        CreateToggle({
            Text = "Kick Player (Loop)",
            Default = false,
            Flag = "KickLoop",

            Callback = function(value)
                kickLoopEnabled =
                    value

                if value then
                    if selectedKickPlayer then
                        MH.StartSingleKickLoop()
                    else
                        pcall(function()
                            kickToggle:
                                SetValue(
                                    false
                                )
                        end)
                    end
                end
            end
        })

BlobSection:CreateToggle({
    Text = "Kick All (Loop)",
    Default = false,
    Flag = "KickAllLoop",

    Callback = function(value)
        kickAllLoopEnabled =
            value

        if value then
            task.spawn(function()
                while kickAllLoopEnabled
                    and State.Running
                do
                    MH.LookAll()

                    task.wait(0.25)
                end
            end)
        end
    end
})

function MH.refreshPlayerDropdowns()
    local newList,
        newMap =
        MH.buildPlayerList()

    State.BlobPlayerMap =
        newMap

    State.TeleportPlayerMap = newMap
    State.ExplosionPlayerMap = newMap

    pcall(function()
        BlobDropdown:Refresh(
            newList
        )
    end)

    pcall(function()
        State.V14.TeleportPlayerDropdown:Refresh(newList)
    end)

    pcall(function()
        State.V14.ExplosionPlayerDropdown:Refresh(newList)
    end)

    local auraList, auraMap = State.V14.buildAuraPlayerList()
    State.AuraFollowPlayerMap = auraMap
    pcall(function()
        State.V14.AuraFollowPlayerDropdown:Refresh(auraList)
    end)

    if selectedKickPlayer
        and not Players:
            FindFirstChild(
                selectedKickPlayer.Name
            )
    then
        selectedKickPlayer = nil
    end

    if State.BlobSelectedPlayer
        and not Players:
            FindFirstChild(
                State.BlobSelectedPlayer.Name
            )
    then
        State.BlobSelectedPlayer = nil
    end
end

MH.connect(
    Players.PlayerAdded,

    function(player)
        if player
            == LocalPlayer
        then
            return
        end

        task.wait(1)

        State.V14.bindEspPlayer(player)
        State.V14.refreshEspForPlayer(player)
        MH.refreshPlayerDropdowns()

        Window:Notify({
            Title = "Player",
            Text = player.DisplayName
                .. " (@"
                .. player.Name
                .. ") entrou",
            Duration = 3
        })
    end
)

MH.connect(
    Players.PlayerRemoving,

    function(player)
        if player
            == LocalPlayer
        then
            return
        end

        if selectedKickPlayer
            == player
        then
            selectedKickPlayer = nil
            kickLoopEnabled = false

            pcall(function()
                kickToggle:
                    SetValue(
                        false
                    )
            end)
        end

        if State.BlobSelectedPlayer
            == player
        then
            State.BlobSelectedPlayer = nil
        end

        if State.TeleportSelectedPlayer == player then
            State.TeleportSelectedPlayer = nil
            State.V14.stopLoopTeleport()
            State.V14.stopLockCamera()
            State.V14.stopViewPlayer()
        end

        if State.ExplosionSelectedPlayer == player then
            State.ExplosionSelectedPlayer = nil
        end

        State.AuraOwnershipLast[player] = nil
        if State.AuraFollowPlayer == player then
            State.AuraFollowPlayer = LocalPlayer
        end

        State.V14.unbindEspPlayer(player)
        State.V14.removeHighlightEsp(player)
        State.V14.removeBillboardEsp(player)
        MH.refreshPlayerDropdowns()

        Window:Notify({
            Title = "Player",
            Text = player.DisplayName
                .. " (@"
                .. player.Name
                .. ") saiu",
            Duration = 3
        })
    end
)


State.V14.HubOwnedFeatureNames = {
    MangaPerspectiveAnchor = true,
    MangaCounterRepulsion = true,
    MangaAttractionBody = true,
    MangaTelekinesisPosition = true,
    MangaTelekinesisGyro = true,
    MangaAuraAnchorPosition = true,
    MangaAuraAnchorGyro = true,
    MangaAuraKickSilent = true,
    MangaAuraKickFloat = true,
    MangaAuraKickSky = true,
    MangaAuraFling = true,
    MangaESPHighlight = true,
    MangaESPBillboard = true
}

function State.V14.cleanupHubOwnedFeatureInstances()
    for _, instance in ipairs(Workspace:GetDescendants()) do
        if State.V14.HubOwnedFeatureNames[instance.Name] or instance:GetAttribute("MangaHubOwned") == true then
            pcall(function()
                instance:Destroy()
            end)
        end
    end
end

State.V14.MangaFeatureController = {}

function State.V14.MangaFeatureController.Stop()
    State.V14.stopPerspectiveGrab()
    State.V14.stopLoopTeleport()
    State.V14.stopLockCamera()
    State.V14.stopViewPlayer()
    State.V14.stopExplosionSpam()
    Config.AutoMakeSnowball = false
    State.V14.stopCrazyLine()
    State.V14.stopLagServer()
    State.V14.setInvisibleLine(false)
    State.V14.stopAuraController()
    State.V14.stopBlobmanLoopKick()
    State.V14.stopBlobmanDestroyServer()
    State.V14.stopEspController()
    State.V14.resetKillGrabState()

    if ENV.MangaInvincibilityController and ENV.MangaInvincibilityController.Stop then
        pcall(ENV.MangaInvincibilityController.Stop)
    end

    local buckets = {}
    for bucketName in pairs(State.FeatureConnections) do
        table.insert(buckets, bucketName)
    end
    for _, bucketName in ipairs(buckets) do
        State.V14.disconnectFeatureBucket(bucketName)
    end

    local workers = {}
    for workerName in pairs(State.FeatureWorkerTokens) do
        table.insert(workers, workerName)
    end
    for _, workerName in ipairs(workers) do
        State.V14.cancelWorker(workerName)
    end

    State.V14.cleanupExplosionToys()
    State.V14.cleanupHubOwnedFeatureInstances()

    if ENV.MangaFeatureController == State.V14.MangaFeatureController then
        ENV.MangaFeatureController = nil
    end
end

ENV.MangaFeatureController = State.V14.MangaFeatureController

State.V14.trackFeatureConnection("FeatureLocalRespawn", LocalPlayer.CharacterAdded:Connect(function()
    local restartAuras = State.V14.auraAnyEnabled()
    State.V14.stopPerspectiveGrab()
    State.V14.stopLoopTeleport()
    State.V14.stopLockCamera()
    State.V14.stopViewPlayer()
    State.V14.stopExplosionSpam()
    Config.AutoMakeSnowball = false
    State.V14.stopCrazyLine()
    State.V14.stopLagServer()
    State.V14.stopBlobmanLoopKick()
    State.V14.stopBlobmanDestroyServer()
    State.V14.stopAuraController()
    State.V14.resetKillGrabState()
    task.delay(0.75, function()
        if State.Running and restartAuras and State.V14.auraAnyEnabled() then
            State.V14.startAuraController()
        end
    end)
end))

OldNamecall = nil

OldNamecall =
    hookmetamethod(
        game,
        "__namecall",
        newcclosure(function(
            self,
            ...
        )
            local method =
                getnamecallmethod()

            local caller =
                false

            if typeof(checkcaller)
                == "function"
            then
                caller =
                    checkcaller()
            end

            if not State.Running
                or method ~= "FireServer"
                or caller
            then
                return OldNamecall(
                    self,
                    ...
                )
            end

            if Config.MasslessGrab
                and EndGrabEarly
                and self == EndGrabEarly
            then
                return nil
            end

            return OldNamecall(
                self,
                ...
            )
        end)
    )

LaunchOldNamecall = nil

LaunchOldNamecall =
    hookmetamethod(
        game,
        "__namecall",
        newcclosure(function(
            self,
            ...
        )
            local method =
                getnamecallmethod()

            local caller =
                false

            if typeof(checkcaller)
                == "function"
            then
                caller =
                    checkcaller()
            end

            if not State.Running
                or method ~= "FireServer"
                or caller
            then
                return LaunchOldNamecall(
                    self,
                    ...
                )
            end

            local args =
                table.pack(
                    ...
                )

            local result =
                table.pack(
                    LaunchOldNamecall(
                        self,
                        ...
                    )
                )

            if self
                == CreateGrabLine
            then
                local object =
                    args[1]

                if MH.valid(object) then
                    State.GrabbedObject =
                        object
                end

            elseif self
                == SetNetworkOwner
            then
                local object =
                    args[1]

                if MH.valid(object) then
                    State.OwnerObject =
                        object

                    State.GrabbedObject =
                        object
                end

            elseif self
                == DestroyGrabLine
            then
                local object =
                    args[1]
                    or State.OwnerObject
                    or State.GrabbedObject

                local button =
                    MH.getReleaseButton()

                local mobileIntent =
                    MH.mobileThrowIntentActive()

                if (
                    button == 2
                    or mobileIntent
                )
                    and MH.valid(object)
                then
                    task.spawn(
                        MH.throwObject,
                        object
                    )
                end

                State.MobileThrowIntentUntil =
                    0

                State.GrabbedObject =
                    nil

                State.OwnerObject =
                    nil

                State.LastMouseButton =
                    0

                State.LastMouseTime =
                    0
            end

            return table.unpack(
                result,
                1,
                result.n
            )
        end)
    )



    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")

    local LocalPlayer = Players.LocalPlayer

    local SilentAim = {
        Enabled = false,
        Distance = 28,
        TargetMode = "cursor",
        TargetPosition = nil
    }

    local function updateTarget()
        if not SilentAim.Enabled then
            SilentAim.TargetPosition = nil
            return
        end

        local camera = Workspace.CurrentCamera
        if not camera then
            SilentAim.TargetPosition = nil
            return
        end

        local referencePos
        if SilentAim.TargetMode == "cursor" then
            referencePos = UserInputService:GetMouseLocation()
        else
            referencePos = Vector2.new(
                camera.ViewportSize.X / 2,
                camera.ViewportSize.Y / 2
            )
        end

        if not referencePos then
            SilentAim.TargetPosition = nil
            return
        end

        local closestPart = nil
        local minScreenDist = math.huge

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                if char then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        local targetPart = char:FindFirstChild("HumanoidRootPart")
                            or char:FindFirstChild("Torso")
                        if targetPart then
                            local worldDist = (targetPart.Position - camera.CFrame.Position).Magnitude
                            if worldDist <= SilentAim.Distance then
                                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                                if onScreen then
                                    local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                                    local screenDist = (screenVec - referencePos).Magnitude
                                    if screenDist < minScreenDist then
                                        minScreenDist = screenDist
                                        closestPart = targetPart
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if closestPart then
            SilentAim.TargetPosition = closestPart.Position
        else
            SilentAim.TargetPosition = nil
        end
    end

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if SilentAim.Enabled
            and SilentAim.TargetPosition
            and self == Workspace
            and method == "Raycast"
        then
            local args = {...}
            if typeof(args[1]) == "Vector3" then
                local origin = args[1]
                local newDir = (SilentAim.TargetPosition - origin).Unit * SilentAim.Distance
                args[2] = newDir
                return oldNamecall(self, unpack(args))
            end
        end
        return oldNamecall(self, ...)
    end))

    RunService.RenderStepped:Connect(updateTarget)

    local SilentAimTab =
        Window:CreateTab(
            "Silent Aim",
            "🎯"
        )

    local SilentAimSection =
        SilentAimTab:
            CreateSection(
                "Silent Aim Settings"
            )

    SilentAimSection:CreateToggle({
        Text = "Silent Aim",
        Default = false,
        Flag = "SilentAimEnabled",
        Callback = function(state)
            SilentAim.Enabled = state
            if not state then
                SilentAim.TargetPosition = nil
            end
        end
    })

    SilentAimSection:CreateDropdown({
        Text = "Target Mode",
        List = { "cursor", "center" },
        Default = "cursor",
        Flag = "SilentAimTargetMode",
        Callback = function(selected)
            SilentAim.TargetMode = selected
        end
    })

    SilentAimSection:CreateSlider({
        Text = "Max Distance",
        Min = 5,
        Max = 100,
        Default = 28,
        Decimals = 0,
        Flag = "SilentAimDistance",
        Callback = function(val)
            SilentAim.Distance = val
        end
    })
