enum QuestStatus {
  active,   
  ready,    
  finished  
}

class QuestModel {
  final String id;
  final String title;
  final String description;
  final int targetAmount;
  int currentAmount;      
  QuestStatus status;
  final String rewardText; 

  QuestModel({
    required this.id,
    required this.title,
    required this.description,
    this.targetAmount = 1,
    this.currentAmount = 0,
    this.status = QuestStatus.active,
    this.rewardText = "",
  });

  void addProgress(int amount) {
    if (status != QuestStatus.active) return;
    
    currentAmount += amount;
    if (currentAmount >= targetAmount) {
      currentAmount = targetAmount;
      status = QuestStatus.ready;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currentAmount': currentAmount,
      'status': status.index,
    };
  }

  void loadFromSave(Map<String, dynamic> json) {
    currentAmount = json['currentAmount'] ?? 0;
    int statusIndex = json['status'] ?? 0;
    status = QuestStatus.values[statusIndex];
  }
}