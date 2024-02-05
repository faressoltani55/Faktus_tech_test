require 'ostruct'
# require 'pry'

class PaymentPlanner
  def initialize(participants)
    @participants = participants
  end

  def payments
    returned_payments = []
    creditors, debtors = @participants.partition { |participant| participant.balance > 0 }

    creditors.each do |creditor|
      while creditor.balance > 0
        debtor = debtors.min_by(&:balance)

        amount = [creditor.balance, -debtor.balance].min
        returned_payments.append(OpenStruct.new(from: debtor, to: creditor, amount: amount))

        creditor.balance -= amount
        debtor.balance += amount
      end
    end
    returned_payments
  end
end

describe PaymentPlanner do

  let(:planner) { described_class.new(participants) }

  describe '#payments' do

    context 'when Paf and Pouf owe to Pif' do
      let(:participants) do
        [
          OpenStruct.new(balance: 500, name: 'Pif'),
          OpenStruct.new(balance: -300, name: 'Paf'),
          OpenStruct.new(balance: -200, name: 'Pouf')
        ]
      end


      it 'returns correct payments' do
        payments = planner.payments

        expect(payments.size).to eq 2

        payment1, payment2 = payments

        expect(payment1.from.name).to eq 'Paf'
        expect(payment1.to.name).to eq 'Pif'
        expect(payment1.amount).to eq 300

        expect(payment2.from.name).to eq 'Pouf'
        expect(payment2.to.name).to eq 'Pif'
        expect(payment2.amount).to eq 200
      end
    end

  end
end
