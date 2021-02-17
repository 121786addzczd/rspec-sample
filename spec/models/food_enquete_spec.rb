require 'rails_helper'

RSpec.describe FoodEnquete, type: :model do
  describe '正常系の機能' do
    context '回答する' do
      it '正しく登録できること 料理:やきそば food_id: 2,
                    満足度:良い score: 3,
                    希望するプレゼント:ビール飲み放題 present_id: 1)' do

        enquete = FoodEnquete.new(
          name: '田中 太郎',
          mail: 'taro.tanaka@example.com',
          age: 25,
          food_id: 2,
          score: 3,
          request: 'おいしかったです。',
          present_id: 1
        )

        # [Point.3-3-2]「バリデーションが正常に通ること(バリデーションエラーが無いこと)」を検証します。
        expect(enquete).to be_valid

        # [Point.3-3-3]テストデータを保存します。
        enquete.save

        @enquete = enquete

        # [Point.3-3-5][Point.3-3-1]で作成したデータを同一か検証します。
        expect(@enquete.name).to eq('田中 太郎')
        expect(@enquete.mail).to eq('taro.tanaka@example.com')
        expect(@enquete.age).to eq(25)
        expect(@enquete.food_id).to eq(2)
        expect(@enquete.score).to eq(3)
        expect(@enquete.request).to eq('おいしかったです。')
        expect(@enquete.present_id).to eq(1)
      end
    end
  end

  describe '入力項目の有無' do
    context '必須入力であること' do
      it 'お名前が必須であること' do
        new_enquete = FoodEnquete.new
        # バリデーションエラーが発生することを検証。
        expect(new_enquete).not_to be_valid
        # 必須入力のメッセージが含まれることを検証。
        expect(new_enquete.errors[:name]).to include(I18n.t('errors.messages.blank'))
      end

      it 'メールアドレスが必須であること' do
        new_enquete = FoodEnquete.new
        expect(new_enquete).not_to be_valid
        expect(new_enquete.errors[:mail]).to include(I18n.t('errors.messages.blank'))
      end

      it '登録できないこと' do
        new_enquete = FoodEnquete.new
        expect(new_enquete.save).to be_falsey
      end
    end

    context '任意入力であること' do
      it 'ご意見・ご要望が任意であること' do
        new_enquete = FoodEnquete.new
        expect(new_enquete).not_to be_valid
        # 必須入力のメッセージが含まれないことを検証。
        expect(new_enquete.errors[:request]).not_to include(I18n.t('errors.messages.blank'))
      end
    end
  end

  describe 'メールアドレスの形式' do
    context '不正な形式のメールアドレスの場合' do
      it 'エラーになること' do
        new_enquete = FoodEnquete.new
        # [Point.3-7-1]不正な形式のメールアドレスを入力します。
        new_enquete.mail = "taro.tanaka"
        expect(new_enquete).not_to be_valid
        # [Point.3-7-2]不正な形式のメッセージが含まれることを検証します。
        expect(new_enquete.errors[:mail]).to include(I18n.t('errors.messages.invalid'))
      end
    end
  end

  describe 'アンケート回答時の条件' do

    context 'メールアドレスを確認すること' do
      it '同じメールアドレスで再び回答できないこと' do
        # 1つ目のテストデータを作成。
        enquete_tanaka = FoodEnquete.new(
          name: '田中 太郎',
          mail: 'taro.tanaka@example.com',
          age: 25,
          food_id: 2,
          score: 3,
          request: 'おいしかったです。',
          present_id: 1
        )
        enquete_tanaka.save

        # 2つ目のテストデータを作成。
        re_enquete_tanaka = FoodEnquete.new(
          name: '田中 太郎',
          mail: 'taro.tanaka@example.com',
          age: 25,
          food_id: 0,
          score: 1,
          request: 'スープがぬるかった',
          present_id: 0
        )
        expect(re_enquete_tanaka).not_to be_valid

        # メールアドレスが既に存在するメッセージが含まれることを検証。
        expect(re_enquete_tanaka.errors[:mail]).to include(I18n.t('errors.messages.taken'))
        expect(re_enquete_tanaka.save).to be_falsey
        expect(FoodEnquete.all.size).to eq 1
      end

      it '異なるメールアドレスで回答できること' do
        enquete_tanaka = FoodEnquete.new(
          name: '田中 太郎',
          mail: 'taro.tanaka@example.com',
          age: 25,
          food_id: 2,
          score: 3,
          request: 'おいしかったです。',
          present_id: 1
        )
        enquete_tanaka.save

        enquete_yamada = FoodEnquete.new(
          name: '山田 次郎',
          mail: 'jiro.yamada@example.com',
          age: 22,
          food_id: 1,
          score: 2,
          request: '',
          present_id: 0
        )

        expect(enquete_yamada).to be_valid
        enquete_yamada.save
        # 問題なく登録できます。
        expect(FoodEnquete.all.size).to eq 2
      end
    end

    context '年齢を確認すること' do
      it '未成年はビール飲み放題を選択できないこと' do
        # 未成年のテストデータを作成。
        enquete_sato = FoodEnquete.new(
          name: '佐藤 仁美',
          mail: 'hitomi.sato@example.com',
          age: 19,
          food_id: 2,
          score: 3,
          request: 'おいしかったです。',
          present_id: 1   # ビール飲み放題
        )

        expect(enquete_sato).not_to be_valid
        # 成人のみ選択できる旨のメッセージが含まれることを検証。
        expect(enquete_sato.errors[:present_id]).to include(I18n.t('activerecord.errors.models.food_enquete.attributes.present_id.cannot_present_to_minor'))
      end

      it '成人はビール飲み放題を選択できないこと' do
        # 未成年のテストデータを作成。
        enquete_sato = FoodEnquete.new(
          name: '佐藤 仁美',
          mail: 'hitomi.sato@example.com',
          age: 20,
          food_id: 2,
          score: 3,
          request: 'おいしかったです。',
          present_id: 1   # ビール飲み放題
        )

        # [「バリデーションが正常に通ること(バリデーションエラーが無いこと)」を検証。
        expect(enquete_sato).to be_valid
      end
    end
  end

  describe '#adult?' do
    it '20歳未満は成人ではないこと' do
      foodEnquete = FoodEnquete.new
      # 未成年になることを検証。
      expect(foodEnquete.send(:adult?, 19)).to be_falsey
    end

    it '20歳以上は成人であること' do
      foodEnquete = FoodEnquete.new
      # 成人になることを検証。
      expect(foodEnquete.send(:adult?, 22)).to be_truthy
    end
  end
end
