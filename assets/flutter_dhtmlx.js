import * as gantt from 'dhtmlxgantt.js';

function initGantt() {
    if (document.getElementById('gantt-container')) {
      gantt.config.date_format = "%Y-%m-%d %H:%i:%s";
        gantt.init('gantt-container');
        gantt.parse({data: []}); // Inicializa com dados vazios
        setupGanttEvents();
    } else {
        setTimeout(initGantt, 50);
    }
}

function setupGanttEvents() {
    gantt.attachEvent('onAfterTaskAdd', function(id, item) {
        console.log('Task added', id, item);
        window.dispatchEvent(new CustomEvent('onTaskAdded', {detail: JSON.stringify({id: id, item: item})}));
    });
    gantt.attachEvent('onAfterTaskUpdate', function(id, item) {
        console.log('Task updated', id, item);
        window.dispatchEvent(new CustomEvent('onTaskUpdated', {detail: JSON.stringify({id: id, item: item})}));
    });
    gantt.attachEvent('onAfterTaskDelete', function(id) {
        console.log('Task deleted', id);
        window.dispatchEvent(new CustomEvent('onTaskDeleted', {detail: JSON.stringify({id: id})}));
    });
}

function addTask(task) {
    task.start_date = new Date(task.start_date); 
    gantt.addTask(task);
}

function updateTask(taskId, changes) {
    if (changes.start_date) {
        changes.start_date = new Date(changes.start_date); 
    }
    var task = gantt.getTask(taskId);
    Object.assign(task, changes);
    gantt.updateTask(taskId);
}

function deleteTask(taskId) {
    gantt.deleteTask(taskId);
}