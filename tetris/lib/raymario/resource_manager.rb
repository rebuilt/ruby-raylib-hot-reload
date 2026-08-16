require "raylib"
class ResourceManager
  include Raylib

  @textures = {}
  @sounds = {}
  @musics = {}

  class << self
    attr_accessor :textures, :sounds, :musics

    def load_resources
      load_textures
      load_sounds
      load_musics
    end

    def unload_resources
      @textures.each_value { |t| UnloadTexture(t) }
      @textures.clear
      @sounds.each_value { |s| UnloadSound(s) }
      @sounds.clear
      @musics.each_value { |m| UnloadMusicStream(m) }
      @musics.clear
    end

    private

    def flip_horizontal(texture)
      image = LoadImageFromTexture(texture)
      ImageFlipHorizontal(image)
      flipped = LoadTextureFromImage(image)
      UnloadImage(image)
      UnloadTexture(texture)
      flipped
    end

    def load_textures
      t = @textures
      path = ->(f) { File.expand_path("../../resources/images/" + f, __dir__) }

      t["smallMario0R"] = LoadTexture(path.call("sprites/mario/SmallMario_0.png"))
      t["smallMario1R"] = LoadTexture(path.call("sprites/mario/SmallMario_1.png"))
      t["smallMario0L"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SmallMario_0.png")))
      t["smallMario1L"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SmallMario_1.png")))

      t["smallMario0RuR"] = LoadTexture(path.call("sprites/mario/SmallMarioRunning_0.png"))
      t["smallMario1RuR"] = LoadTexture(path.call("sprites/mario/SmallMarioRunning_1.png"))
      t["smallMario0RuL"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SmallMarioRunning_0.png")))
      t["smallMario1RuL"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SmallMarioRunning_1.png")))

      t["smallMario0JuR"] = LoadTexture(path.call("sprites/mario/SmallMarioJumping_0.png"))
      t["smallMario0JuL"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SmallMarioJumping_0.png")))
      t["smallMario0JuRuR"] = LoadTexture(path.call("sprites/mario/SmallMarioJumpingAndRunning_0.png"))
      t["smallMario0JuRuL"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SmallMarioJumpingAndRunning_0.png")))
      t["smallMario0FaR"] = LoadTexture(path.call("sprites/mario/SmallMarioFalling_0.png"))
      t["smallMario0FaL"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SmallMarioFalling_0.png")))
      t["smallMario0LuR"] = LoadTexture(path.call("sprites/mario/SmallMarioLookingUp_0.png"))
      t["smallMario0LuL"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SmallMarioLookingUp_0.png")))
      t["smallMario0DuR"] = LoadTexture(path.call("sprites/mario/SmallMarioDucking_0.png"))
      t["smallMario0DuL"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SmallMarioDucking_0.png")))
      t["smallMario0Vic"] = LoadTexture(path.call("sprites/mario/SmallMarioVictory_0.png"))
      t["smallMario0Dy"] = LoadTexture(path.call("sprites/mario/SmallMarioDying_0.png"))
      t["smallMario1Dy"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SmallMarioDying_0.png")))

      t["superMario0R"] = LoadTexture(path.call("sprites/mario/SuperMario_0.png"))
      t["superMario1R"] = LoadTexture(path.call("sprites/mario/SuperMario_1.png"))
      t["superMario2R"] = LoadTexture(path.call("sprites/mario/SuperMario_2.png"))
      t["superMario0L"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SuperMario_0.png")))
      t["superMario1L"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SuperMario_1.png")))
      t["superMario2L"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SuperMario_2.png")))
      t["superMario0RuR"] = LoadTexture(path.call("sprites/mario/SuperMarioRunning_0.png"))
      t["superMario1RuR"] = LoadTexture(path.call("sprites/mario/SuperMarioRunning_1.png"))
      t["superMario2RuR"] = LoadTexture(path.call("sprites/mario/SuperMarioRunning_2.png"))
      t["superMario0RuL"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SuperMarioRunning_0.png")))
      t["superMario1RuL"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SuperMarioRunning_1.png")))
      t["superMario2RuL"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SuperMarioRunning_2.png")))
      t["superMario0JuR"] = LoadTexture(path.call("sprites/mario/SuperMarioJumping_0.png"))
      t["superMario0JuL"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SuperMarioJumping_0.png")))
      t["superMario0JuRuR"] = LoadTexture(path.call("sprites/mario/SuperMarioJumpingAndRunning_0.png"))
      t["superMario0JuRuL"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SuperMarioJumpingAndRunning_0.png")))
      t["superMario0FaR"] = LoadTexture(path.call("sprites/mario/SuperMarioFalling_0.png"))
      t["superMario0FaL"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SuperMarioFalling_0.png")))
      t["superMario0LuR"] = LoadTexture(path.call("sprites/mario/SuperMarioLookingUp_0.png"))
      t["superMario0LuL"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SuperMarioLookingUp_0.png")))
      t["superMario0DuR"] = LoadTexture(path.call("sprites/mario/SuperMarioDucking_0.png"))
      t["superMario0DuL"] = flip_horizontal(LoadTexture(path.call("sprites/mario/SuperMarioDucking_0.png")))
      t["superMario0Vic"] = LoadTexture(path.call("sprites/mario/SuperMarioVictory_0.png"))

      t["goomba0R"] = LoadTexture(path.call("sprites/baddies/Goomba_0.png"))
      t["goomba1R"] = LoadTexture(path.call("sprites/baddies/Goomba_1.png"))
      t["goomba0L"] = flip_horizontal(LoadTexture(path.call("sprites/baddies/Goomba_0.png")))
      t["goomba1L"] = flip_horizontal(LoadTexture(path.call("sprites/baddies/Goomba_1.png")))

      t["blockStone"] = LoadTexture(path.call("sprites/blocks/Stone_0.png"))
      t["blockQuestion0"] = LoadTexture(path.call("sprites/blocks/Question_0.png"))
      t["blockQuestion1"] = LoadTexture(path.call("sprites/blocks/Question_1.png"))
      t["blockQuestion2"] = LoadTexture(path.call("sprites/blocks/Question_2.png"))
      t["blockQuestion3"] = LoadTexture(path.call("sprites/blocks/Question_3.png"))
      t["blockWood"] = LoadTexture(path.call("sprites/blocks/Wood_0.png"))
      t["blockExclamation"] = LoadTexture(path.call("sprites/blocks/Exclamation_0.png"))
      t["blockEyesClosed"] = LoadTexture(path.call("sprites/blocks/EyesClosed_0.png"))
      t["blockEyesOpened0"] = LoadTexture(path.call("sprites/blocks/EyesOpened_0.png"))
      t["blockEyesOpened1"] = LoadTexture(path.call("sprites/blocks/EyesOpened_1.png"))
      t["blockEyesOpened2"] = LoadTexture(path.call("sprites/blocks/EyesOpened_2.png"))
      t["blockEyesOpened3"] = LoadTexture(path.call("sprites/blocks/EyesOpened_3.png"))
      t["blockCloud"] = LoadTexture(path.call("sprites/blocks/Cloud_0.png"))
      t["blockGlass"] = LoadTexture(path.call("sprites/blocks/Glass_0.png"))
      t["blockMessage"] = LoadTexture(path.call("sprites/blocks/Message_0.png"))

      t["coin0"] = LoadTexture(path.call("sprites/items/Coin_0.png"))
      t["coin1"] = LoadTexture(path.call("sprites/items/Coin_1.png"))
      t["coin2"] = LoadTexture(path.call("sprites/items/Coin_2.png"))
      t["coin3"] = LoadTexture(path.call("sprites/items/Coin_3.png"))
      t["mushroom"] = LoadTexture(path.call("sprites/items/Mushroom.png"))
      t["fireFlower0"] = LoadTexture(path.call("sprites/items/FireFlower_0.png"))
      t["fireFlower1"] = LoadTexture(path.call("sprites/items/FireFlower_1.png"))
      t["star"] = LoadTexture(path.call("sprites/items/Star.png"))
      t["1UpMushroom"] = LoadTexture(path.call("sprites/items/1UpMushroom.png"))

      t["puft0"] = LoadTexture(path.call("sprites/effects/Puft_0.png"))
      t["puft1"] = LoadTexture(path.call("sprites/effects/Puft_1.png"))
      t["puft2"] = LoadTexture(path.call("sprites/effects/Puft_2.png"))
      t["puft3"] = LoadTexture(path.call("sprites/effects/Puft_3.png"))

      (1..10).each do |i|
        t["background#{i}"] = LoadTexture(path.call("backgrounds/background#{i}.png"))
      end

      %w[guiAlfa guiAlfaLowerUpper guiClock guiCoin guiCredits guiGameOver guiLetters guiMario guiMarioStart guiNextItem guiNumbersBig guiNumbersWhite guiNumbersYellow guiPunctuation guiRayMarioLogo guiTime guiTimeUp guiX gui1Up gui2Up gui3Up].each do |key|
        t["gui_#{key}"] = LoadTexture(path.call("gui/#{key}.png"))
      end
    end

    def load_sounds
      return unless @sounds.empty?
      InitAudioDevice unless Raylib.IsAudioDeviceReady

      mapping = {
        "1up" => "smw_1-up",
        "breakBlock" => "smw_break_block",
        "coin" => "smw_coin",
        "chuckWhistle" => "smw_chuck_whistle",
        "dragonCoin" => "smw_dragon_coin",
        "fireball" => "smw_fireball",
        "goalIrisOut" => "smw_goal_iris-out",
        "jump" => "smw_jump",
        "kick" => "smw_kick",
        "messageBlock" => "smw_message_block",
        "pause" => "smw_pause",
        "pipe" => "smw_pipe",
        "powerUp" => "smw_power-up",
        "powerUpAppears" => "smw_power-up_appears",
        "reserveItemRelease" => "smw_reserve_item_release",
        "reserveItemStore" => "smw_reserve_item_store",
        "ridingYoshi" => "smw_riding_yoshi",
        "shellRicochet" => "smw_shell_ricochet",
        "stomp" => "smw_stomp",
        "stompNoDamage" => "smw_stomp_no_damage",
      }

      mapping.each do |key, file|
        @sounds[key] = LoadSound(File.expand_path("../../resources/sfx/#{file}.wav", __dir__))
      end
    end

    def load_musics
      return unless @musics.empty?
      InitAudioDevice unless Raylib.IsAudioDeviceReady

      %w[courseClear ending gameOver invincible music1 music2 music3 music4 music5 music6 music7 music8 music9 playerDown title].each do |key|
        @musics[key] = LoadMusicStream(File.expand_path("../../resources/musics/#{key}.mp3", __dir__))
      end
    end
  end
end
